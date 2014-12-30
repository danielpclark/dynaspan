##Dynaspan
[![Gem Version](https://badge.fury.io/rb/dynaspan.svg)](http://badge.fury.io/rb/dynaspan)
#####[JSFiddle Demo](http://jsfiddle.net/680v09y8/)

Dynaspan is an AJAX tool for Rails to update one field of any object without interfering with your website experience.  The user will see the web page as normal text.  Where ever you've placed a Dynaspan field people can click on the text and it transforms into text entry.  As soon as the person moves away from that entry it sends the update to the server.

Dynaspan also accepts updating an attribute for a nested object, but only 1 level deep.

###Installation

 - [ ] Add `gem 'dynaspan'` to your Gemfile.
 - [ ] Run `bundle`.
 - [ ] Next add `include Dynaspan::ApplicationHelper` inside your **ApplicationHelper** module.
 - [ ] Add `//= require dynaspan/dynaspan` to your **application.js** file.
 - [ ] And it's installed!

###Usage

Example #1:

    dynaspan_text_field(@article, comment, :note, '[edit]')
    
Example #2:

    dynaspan_text_field(profile, profile.websites, :url, '[edit]',
                        {hidden_field: {page_name: 'page2'}, callback_on_update: "alert('Awesome!');"})

This will show the value of note in the comment object as plain text.  It can be clicked on to instantly become a text field input.  And once unselected the `@article` object will update with its nested attribute object `comment` and its new value in the `note` attribute.

You can use either `dynaspan_text_field` or `dynaspan_text_area` in any of your views.  There are two mandatory parameters.  The first is a the main Object model instance you will be updating.  And the other mandatory field is the symbol of the attribute to update.  There are two optional fields.  The first is the nested attribute object which will have its field updated.  And the last is the optional text for `[edit]`-ing (clicking on to edit which is useful for blank fields).

    dynaspan_text_field(Object,OptionalNestedObject,SymField,OptionalEditText,OptionalOptionsHash)
    dynaspan_text_area(Object,OptionalNestedObject,SymField,OptionalEditText,OptionalOptionsHash)

The order is important.  And yes it does NOT change even if you just do:

    dynaspan_text_field(Object,SymField)

It is unconventional but the order remains the same despite the optional fields.

###How it updates

The AJAX call will call the update method on your first Object parameter via PATCH.  The optional nested attribute and the symbol for the field are all part of the main Object being updated.  There is no expected AJAX reply.  It's a silent set it and forget it method.  If you don't have your update method configured with a `.js` response then it will successfully perform the update on the object, and then send a complaint about a response but no one will notice (unless maybe you look at the server logs).  In other words the client experience is only good, and the server won't hiccup over it.

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

####Version 0.1.0

Added the same hidden_fields from version 0.0.8 to support non-nested Objects.  You can use them now on anything.

####Version 0.0.9

JavaScript callback option now available.  Whenever the Dynaspan field is submitted you can have Dynaspan call
your own JavaScript method.

    {
      callback_on_update: "someMethod('some-relative-instance-value');"
    }

####Version 0.0.8

You can now provide an option hash as a last parameter.  Current
valid options only include:

    {
      hidden_fields: { label: "value" }
    }
    
You can add as many hidden fields to your Dynaspan objects as you'd like.

>NOTE: In this version hidden fields only apply for nested attributes.

Also the id parameter will only be passed to the server if it exists.  (No more empty
string for id.)  This allows you to create "new" polymorphic child objects with Dynaspan.

###License

The MIT License (MIT)

Copyright (C) 2014 by Daniel P. Clark

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

