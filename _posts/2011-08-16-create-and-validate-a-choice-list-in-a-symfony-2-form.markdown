--- 
layout: post
title: Create and Validate a Choice List in a Symfony 2 Form
category: php
excerpt: There is a lot of magic going on in the Symfony 2 form component, and while this magic is frequently convenient and borderline awe-inspiring, it sometimes has the unpleasant side effect of making it unclear how to do more fine-grained tasks within the form.  A standard select list can be created using Symfony's choice field type; it is pretty clear how to create a new choice field with simple, non-dynamic options (e.g. gender), but it gets a little more complicated when you want to create and validate a dynamically generated choice list. [...]
date: 2011-08-16 15:00:56 -04:00
legacy_id: http://epixa.com/?p=359
---

Create and Validate a Choice List in a Symfony 2 Form
=====================================================

There is a lot of magic going on in the Symfony 2 form component, and while this magic is frequently convenient and borderline awe-inspiring, it sometimes has the unpleasant side effect of making it unclear how to do more fine-grained tasks within the form.  A standard select list can be created using Symfony's [choice][choice-field] field type; it is pretty clear how to create a new choice field with simple, non-dynamic options (e.g. gender), but it gets a little more complicated when you want to create and validate a dynamically generated choice list.

[choice-field]: http://symfony.com/doc/current/reference/forms/types/choice.html

When creating your choice field, you can specify which options are available by either passing an array of options ("choices") or by passing a custom object that implements \Symfony\Component\Form\Extension\Core\ChoiceList\ChoiceListInterface ("choice_list").  For this article, I will be focussing on the latter, but this can all be very easily adapted to a simple choices array.

Choice Lists and Doctrine 2 Entities
------------------------------------
If the model that you bind to your form type is a doctrine 2 entity, then chances are the vast majority of your choice field's form logic will be taken care of for you.  If you add a form field that matches an entity property that has an association to another entity, then Symfony guesses the correct form field type, retrieves the form field options, and even validates your input to make sure it is a valid option.  It is, for the lack of a better term, awesome:

We'll need an entity:

{% highlight php %}
<?php

namespace Epixa\\Entity;

use Doctrine\\ORM\\Mapping as ORM;

/**
 * @ORM\\Entity
 */
class Post
{
    // ... other post properties

    /**
     * @ORM\\ManyToOne(targetEntity="Epixa\\Entity\\Category")
     */
    protected $category;

    // ... appropriate getters an setters
}
{% endhighlight %}

We'll also need a form type:

{% highlight php %}
<?php

namespace Epixa\\Form\\Type;

use Symfony\\Component\\Form\\AbstractType,
    Symfony\\Component\\Form\\FormBuilder;

class PostType extends AbstractType
{
    public function buildForm(FormBuilder $builder, array $options)
    {
        // ... add other appropriate form fields

        $this->add('category');
    }

    public function getDefaultOptions(array $options)
    {
        return array(
            'data_class' => 'Epixa\\Entity\\Post'
        );
    }

    public function getName()
    {
        return 'epixa_post';
    }
}
{% endhighlight %}

Tie it all together with your action:

{% highlight php %}
<?php

public function addAction($topicId, Request $request)
{
    $post = new \\Epixa\\Entity\\Post($topic);

    $form = $this->createForm(new \\Epixa\\Form\\Type\\PostType(), $post);

    if ($request->getMethod() == 'POST') {
        $form->bindRequest($request);

        if ($form->isValid()) {
            // ... persist the $post in the db and redirect away
        }
    }

    return array(
        'form' => $form->createView()
    );
}
{% endhighlight %}

With that code in place, your form will have a select field that lists all categories as options, and validation will ensure that not only is a category provided but also that the category is one of the available options.  *Note: your category entity will need to have a __toString() method defined as this is used as the human-readable component of a select option.*

Creating and Validating Non-Entity Models
-----------------------------------------
Sometimes it is necessary to use a model in your form type that is not itself a Doctrine entity.  Personally, I have encountered this mostly when dealing with deletion forms.  Consider this scenario: let's say you are adding functionality to delete a specific Category entity (the same category that is referenced in our previous Post example), but in order to delete a category, you need to choose where all of its child posts should be moved.  In this case, you want to display a select field with all possible categories, but you don't have the wonderful benefits of a doctrine entity with an association defined.

In this situation, create a new model to represent your deletion parameters, attach it to a form that is designed to render and validate the available parameters, and then use that model to perform the necessary business logic to move the child posts and delete the category.  Again, let's go with an example.

The model here is a little more complex than the previous entity; pay careful attention to the "assert" annotations that I use here:

{% highlight php %}
<?php

namespace Epixa\\Model;

use Epixa\\Entity\Category,
    Symfony\\Component\\Validator\\Constraints as Assert,
    Symfony\\Component\\Form\\Extension\\Core\\ChoiceList\\ChoiceListInterface,
    Symfony\\Component\\Validator\\ExecutionContext;

/**
 * @Assert\\Callback(methods = {"isInheritingCategoryValid"})
 */
class CategoryDeletionParams
{
    /**
     * @Assert\\NotBlank()
     */
    protected $inheritingCategoryId;

    protected $choices = null;

    public function setInheritingCategoryId($id)
    {
        $this->inheritingCategoryId = (int)$id;
        return $this;
    }

    public function getInheritingCategoryId()
    {
        return $this->inheritingCategoryId;
    }

    public function setInheritingCategoryChoices(ChoiceListInterface $choices)
    {
        $this->choices = $choices;
        return $this;
    }

    public function getInheritingCategoryChoices()
    {
        return $this->choices;
    }

    public function isInheritingCategoryValid(ExecutionContext $context)
    {
        $choiceList = $this->getInheritingCategoryChoices();
        if (!$choiceList) {
            throw new \LogicException('No choice list configured');
        }
        
        $choices = $this->getInheritingCategoryChoices()->getChoices();
        if (!array_key_exists($this->getInheritingCategoryId(), $choices)) {
            $propertyPath = $context->getPropertyPath() . '.inheritingCategoryId';
            $context->setPropertyPath($propertyPath);
            $context->addViolation('Invalid category', array(), null);
        }
    }
}
{% endhighlight %}

The NotBlank assertion on the $inheritingCategoryId ensures that a category id is required.  The Callback assertion on the class ensures that the given category id is actually one of the available options.  *Note: Callback assertions cannot be placed on properties.*

Now for the form type:

{% highlight php %}
<?php

namespace Epixa\\Form\\Type;

use Symfony\\Component\\Form\\AbstractType,
    Symfony\\Component\\Form\\FormBuilder,
    Epixa\\Model\\CategoryDeletionParams;

class DeleteCategoryType extends AbstractType
{
    public function buildForm(FormBuilder $builder, array $options)
    {
        if (!isset($options['data']) || !($options['data'] instanceof CategoryDeletionParams)) {
            throw new \LogicException('No valid options provided');
        }

        $deletionParams = $options['data'];

        $builder->add('inheritingCategoryId', 'choice', array(
            'label' => 'Move all posts to:',
            'choice_list' => $deletionParams->getInheritingCategoryChoices()
        ));
    }

    public function getDefaultOptions(array $options)
    {
        return array(
            'data_class' => 'Epixa\\Model\\CategoryDeletionParams'
        );
    }

    public function getName()
    {
        return 'epxia_delete_category';
    }
}
{% endhighlight %}

In this form type, we have to do a little more leg work than we did before.  The form builder doesn't have enough information to guess all of the field's details like it did with the doctrine entity, so we needed to specify that this is a "choice" field, with a custom label, and populated by a specific choice_list.

Next up?  You guessed it; the action:

{% highlight php %}
<?php

public function deleteAction($id, Request $request)
{
    // ... retrieve $category entity that matches the $id

    // This should be located in its own service. I am including it here to get the message across.
    $entityName = 'Epixa\\Entity\\Category';
    $em = $this->getDoctrine()->getEntityManager();
    $qb = $em->getRepository($entityName)->createQueryBuilder('c');
    $qb->where('c.id <> :category_id'); // we don't want to include the category we're deleting
    $qb->setParameter('category_id', $category->getId());
    $choiceList = new \\Symfony\\Bridge\\Doctrine\\Form\\ChoiceList\\EntityChoiceList($em, $entityName, null, $qb);

    $deletionParams = new \\Epixa\\Model\\CategoryDeletionParams();
    $deletionParams->setInheritingCategoryChoices($choiceList);

    $form = $this->createForm(new \\Epixa\\Form\\Type\\DeleteCategoryType(), $deletionParams);

    if ($request->getMethod() == 'POST') {
        $form->bindRequest($request);

        if ($form->isValid()) {
            // ... move all child posts to the category identified by $deletionParams->getInheritingCategoryId()
            // ... delete $category and redirect away
        }
    }

    return array(
        'form' => $form->createView()
    );
}
{% endhighlight %}

The controller above is a little rough.  I included a lot of logic in there that should really go into a separate service, but I didn't want the complication of the example getting in way of the meat of the issue.

That's it!  When you render the form, it will provided a Symfony 2 choice field rendered as a select field that is populated with all of the categories (except the one we're deleting).  When you submit the form, it will check to make sure that not only is a category selected but also that the selection is actually one of the categories in the system.

I'm still only breaking the surface of the Symfony 2 form component, and I am finding that for all of incredible convenience that is provided for very common functionality there is likely an equal amount of frustration when trying to implement more specific pieces of functionality.  That said, the component is certainly powerful, and I haven't yet come across a scenario that it couldn't handle.

**Know of an easier way to do this?** By all means let me know!  I am eager to simplify processes like this as I expect to be doing this kind of thing frequently.


Edit (Aug 08 2010 4:40pm):
--------------------------

[@Bernhard][bernhard] has provided an approach that seems to be much more in line with the usage that symfony devs envisioned.  He notes that the [entity][entity-field] field type takes care of validation for you and provides a convenient way to populate the select options as well.  I've revised his example code only so much as to fit with the previous examples and execute properly:

[bernhard]: http://webmozarts.com/
[entity-field]: http://symfony.com/doc/current/reference/forms/types/entity.html

Deletion parameters model:

{% highlight php %}
<?php

namespace Epixa\\Model;

use Symfony\\Component\\Validator\\Constraints as Assert;

class CategoryDeletionParams
{
    protected $targetCategory;

    /**
     * @Assert\\NotBlank()
     */
    protected $inheritingCategory = null;

    // ... appropriate setters and getters
}
{% endhighlight %}

Form type:

{% highlight php %}
<?php

namespace Epixa\\Form\\Type;

use Symfony\\Component\\Form\\AbstractType,
    Symfony\\Component\\Form\\FormBuilder,
    Symfony\\Component\\Form\\FormEvents,
    Symfony\\Component\\Form\\Event\\DataEvent,
    Doctrine\\ORM\\EntityRepository,
    Epixa\\Model\\CategoryDeletionParams;

class DeleteCategoryType extends AbstractType
{
    public function buildForm(FormBuilder $builder, array $options)
    {
        // creates the inheriting select field whenever the data (deletion params model) is set
        $builder->addEventListener(FormEvents::PRE_SET_DATA, function(DataEvent $event) use ($builder){
            $data = $event->getData();
            if (!$data instanceof CategoryDeletionParams) {
                return; // $data is null when form is first constructed
            }

            $event->getForm()->add($builder->create('inheritingCategory', 'entity', array(
                'label' => 'Move all posts to:',
                'class' => 'Epixa\\Entity\\Category',
                'query_builder' => function(EntityRepository $repo) use ($data){
                    $qb = $repo->createQueryBuilder('c');
                    $qb->where('c.id <> :category_id');
                    $qb->setParameter(‘category_id’, $data->getTargetCategory()->getId());
                    return $qb;
                }
            ))->getForm());
        });
    }

    // ...
}
{% endhighlight %}

Action:

{% highlight php %}
<?php
public function deleteAction($id, Request $request)
{
    // ... retrieve $category that matches $id

    $params = new \\Epixa\\Model\\CategoryDeletionParams($category);
    $form = $this->createForm(new \\Epixa\\Form\\Type\\DeleteCategoryType(), $params);

    if ($request->getMethod() == 'POST') {
        $form->bindRequest($request);

        if ($form->isValid()) {
            // ... move child posts to inheriting category, delete target category, redirect away
        }
    }

    return array(
        'form' => $form->createView()
    );
}
{% endhighlight %}

I think this approach is much clearer than my original example.  Thanks Bernhard!