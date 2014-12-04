##Dynaspan

Dynaspan is an AJAX tool for Rails to update one field of any object without interfering with your website experience.  The user will see the web page as normal text.  Where ever you've placed a Dynaspan field people can click on the text and it transforms into text entry.  As soon as the person moves away from that entry it sends the update to the server.

Dynaspan also accepts updating an attribute for a nested object, but only 1 level deep.

###Installation

 - [ ] Add `gem 'dynaspan'` to your Gemfile.
 - [ ] Run `bundle`.
 - [ ] Next add `include Dynaspan::ApplicationHelper` inside your **ApplicationHelper** module.
 - [ ] And it's installed!

###Usage

Example:

    dynaspan_text_field(@article, comment, :note, '[edit]')

This will show the value of note in the comment object as plain text.  It can be clicked on to instantly become a text field input.  And once unselected the `@article` object will update with its nested attribute object `comment` and its new value in the `note` attribute.

You can use either `dynaspan_text_field` or `dynaspan_text_area` in any of your views.  There are two mandatory parameters.  The first is a the main Object model instance you will be updating.  And the other mandatory field is the symbol of the attribute to update.  There are two optional fields.  The first is the nested attribute object which will have its field updated.  And the last is the optional text for `[edit]`-ing (clicking on to edit which is useful for blank fields).

    dynaspan_text_field(Object,OptionalNestedObject,SymField,OptionalEditText)
    dynaspan_text_area(Object,OptionalNestedObject,SymField,OptionalEditText)

The order is important.  And yes it does NOT change even if you just do:

    dynaspan_text_field(Object,SymField)

It is unconventional but the order remains the same despite the optional fields.

###How it updates

The AJAX call will call the update method on your first Object parameter via PATCH.  The optional nested attribute and the symbol for the field are all part of the main Object being updated.  There is no expected AJAX reply.  It's a silent set it and forget it method.  If you don't have your update method configured with a `.js` response then it will successfully perform the update on the object, and then send a complaint about a response but no one will notice (unless maybe you look at the server logs).  In other words the client experience is only good, and the server won't hiccup over it.

###It's too easy!

**You're welcome!**

-- Daniel P. Clark

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

