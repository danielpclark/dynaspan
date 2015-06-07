##Dynaspan
[![Gem Version](https://badge.fury.io/rb/dynaspan.svg)](http://badge.fury.io/rb/dynaspan)
[![Code Climate](https://codeclimate.com/github/danielpclark/dynaspan/badges/gpa.svg)](https://codeclimate.com/github/danielpclark/dynaspan)
#####[JSFiddle Demo](http://jsfiddle.net/680v09y8/)

Dynaspan is an AJAX tool for Rails to update one field of any object without interfering with your website experience.  The user will see the web page as normal text.  Where ever you've placed a Dynaspan field people can click on the text and it transforms into text entry.  As soon as the person moves away from that entry it sends the update to the server.

Dynaspan also accepts updating an attribute for a nested object, but only 1 level deep.

###Installation

 - [ ] Add `gem 'dynaspan'` to your Gemfile
 - [ ] Run `bundle`
 - [ ] Next add `include Dynaspan::ApplicationHelper` inside your **ApplicationHelper** module
 - [ ] Add `//= require dynaspan/dynaspan` to your **application.js** file

And it's installed!

###Usage

Simple example:
```ruby
dynaspan_text_field(user, :name)
```
And that's it.  As long as you have a User object with a name field, this will update through
the UserController's update method.  **user** is an User Object instance eg: `user = User.first`.

---

Polymorphic/Nested Example #1:
```ruby
dynaspan_text_field(@article, comment, :note, '[edit]')
```
Polymorphic/Nested Example #2:
```ruby
dynaspan_text_field(profile, profile.websites, :url, '[edit]',
                     {
                       hidden_fields: {page_name: 'page2'},
                       callback_on_update: "alert('Awesome!');"
                     }
                   )
```
This will show the value of note in the comment object as plain text.  It can be clicked on to instantly become a text field input.  And once unselected the `@article` object will update with its nested attribute object `comment` and its new value in the `note` attribute.

You can use either `dynaspan_text_field` or `dynaspan_text_area` in any of your views.  There are two mandatory parameters.  The first is a the main Object model instance you will be updating.  And the other mandatory field is the symbol of the attribute to update.  There are two optional fields.  The first is the nested attribute object which will have its field updated.  And the last is the optional text for `[edit]`-ing (clicking on to edit which is useful for blank fields).
```ruby
dynaspan_text_field(Object,OptionalNestedObject,SymField,OptionalEditText,OptionalOptionsHash)
dynaspan_text_area(Object,OptionalNestedObject,SymField,OptionalEditText,OptionalOptionsHash)
dynaspan_select(Object,OptionalNestedObject,SymField,OptionalEditText,OptionsHash)
```
The order is important.  And yes it does NOT change even if you just do:
```ruby
dynaspan_text_field(Object,SymField)
```
It is unconventional but the order remains the same despite the optional fields.

###Parameters

The **first** parameter will always be the Object that will have its update method called.  It must be an instance of the Object.
For example current_user being an instance of User.

The **second** parameter can be a symbol of the field you want to update on the main Object from the first parameter.

The **second** field can also be a has_one or has_many subset of the first argument moving the symbol to modify to the **third** argument.
For example **dynaspan_text_field(author, author.stories, :title)**.  This works as a nested attribute so it includes Polymorphic Objects.

The last two parameters can be edit text, and then additional options (in that order).  Both are optional.  The edit text
is a way to be able to click somewhere to open up the input to initially enter text.

The options Hash currently has these options.

 - **:hidden_fields** will put in as many hidden fields as you include in a Hash with key->value matching to name->value
 - **:callback_on_update** is a no frills callback.  It runs whatever command you give it whenever Dynaspan submits an update to the server
 - **:callback_with_values** will allow you to put a JavaScript command you want called on update and include as many parameters as you'd like.  It will dynamically append a last parameter which is a Hash of two values.  The first is the CSS selector id of the Dynaspan block that just performed the action, the second value is the actual text that was entered.  The keys in this Hash are **ds_selector** and **ds_input**
 - **:unique_id** allows custom ID labelling which is ideal for JavaScript generated usage.
 - **:form_for** allows adding or over-writing any form_for parameter (besides the object being written to). This takes a Hash of parameters just like you would give in a view for your form_for form.  If you have a namespaced object to update use the **url:** option in the hash for the path to use in updating your object.
 - **:html_options** add your own html options to the input field.  Includes ability to add additional classes with `html_options: {class: "example"}`.  **:id**, **:onfocus**, and **:onblur** are reserved.
 - **:choices** used for **dynaspan_select** for the choices of the select box.
 - **:options** used for **dynaspan_select** for the options of the select box; such as **:disabled**, **:prompt**, or **:include_blank**.
 - **&block** used only with **dynaspan_select** for passing a block to Rails' form select method.

###How it updates

The AJAX call will call the update method on your first Object parameter via PATCH.  The optional nested attribute
and the symbol for the field are all part of the main Object being updated.  There is no expected AJAX reply.  It's
a silent set it and forget it method.  If you don't have your update method configured with a `.js` response then it
will successfully perform the update on the object, and then send a complaint about a response but no one will notice
(unless maybe you look at the server logs).  In other words the client experience is only good, and the server
won't hiccup over it.

###It's too easy!

**You're welcome!**

-- Daniel P. Clark

###Styles

As of version 0.0.6 a class will be dynamically added/removed to a div tag containing the class "dyna-span".
That class is "ds-content-present".  The purpose of this class is to allow CSS content styles depending on
whether your text exists or not.  The '[edit]' text you can use as a parameter normally drops below the input
box.  If you don't want it to drop you can style it with the proper CSS selector for content present.  E.G.
`.ds-content-present > dyna-span-edit-text { margin-top:-18px; }` You can set the height to whatever your input
field height is to maintain the position of the edit text.

In version 0.0.7 I've added a class to the parent div object for when the text field dialog is open.  The class
is "ds-dialog-open". This is also to use in CSS styles.  This feature was added since CSS doesn't support
calling parents with selectors.  Example usage:

```css
.ds-content-present > .dyna-span-edit-text {
  margin-top:-18px;
}

.ds-dialog-open > .dyna-span-edit-text {
  margin-top:-24px;
}
```

###What's New

####Version 0.1.3

Changed **:unique_id** to work based on the object being rendered and some additional random characters in case the same object will be used more than once.

Added **:html_options** add your own html options to the input field.  Includes ability to add additional classes with `html_options: {class: "example"}`.  **:id**, **:onfocus**, and **:onblur** are reserved.

Added **dynaspan_select** for having a select box dynamically appear.
 - Added **:choices** used for **dynaspan_select** for the choices of the select box.
 - Added **:options** used for **dynaspan_select** for the options of the select box; such as **:disabled**, **:prompt**, or **:include_blank**.
 - Added **&block** used only with **dynaspan_select** for passing a block to Rails' form select method.



####Version 0.1.2

Added **unique_id** parameter to the options Hash allowing custom ID labelling which is ideal for JavaScript generated usage.

Added **form_for** parameter to allow adding or over-writing any form_for parameter (besides the object being written to).
If you have a namespaced object to update use the **url:** option in the hash for the path to use in updating your object.

####Version 0.1.1

Added a JavaScript callback that will **append** a Hash/Dictionary of the updated Dynaspan Object to the end of your
functions parameters.  The method is named **callback_with_values**.
```ruby
{
  callback_with_values: "console.log();"
}
```
This will be called everytime the Dynaspan field submits and it will **inject** the following result **as the last parameter**:
```ruby
{
  ds_selector: "dyna_span_unique_label<#>",
  ds_input:    "the entered text from the input field"
}
```
####Version 0.1.0

Added the same hidden_fields from version 0.0.8 to support non-nested Objects.  You can use them now on anything.

####Version 0.0.9

JavaScript callback option now available.  Whenever the Dynaspan field is submitted you can have Dynaspan call
your own JavaScript method.
```ruby
{
  callback_on_update: "someMethod('some-relative-instance-value');"
}
```
####Version 0.0.8

You can now provide an option hash as a last parameter.  Current
valid options only include:
```ruby
{
  hidden_fields: { label: "value" }
}
```
You can add as many hidden fields to your Dynaspan objects as you'd like.

>NOTE: In this version hidden fields only applies to nested attributes.

Also the id parameter will only be passed to the server if it exists.  (No more empty
string for id.)  This allows you to create "new" polymorphic child objects with Dynaspan.

###License

The MIT License (MIT)

Copyright (C) 2014-2015 by Daniel P. Clark

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

