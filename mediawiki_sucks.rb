#!/usr/bin/ruby -w

require "yaml"

class String
  def strip_heading
    sub(/^=+ ([^=]+) =+$/, '\1')
  end
end

def new_lesson
  keys = %w[section_content section_title goal_title goal explanation steps]
  Hash[keys.map { |k| [k, []] }]
end

key_map = {
  "what just happened?" => "explanation"
}

goals = []
lesson = nil
mode = nil

DATA.each_line do |line|
  case line
  when /^== ([^=]+) ==/ then
    section_title = $1

    lesson = new_lesson
    goals << lesson

    lesson["section_title"] = section_title
    mode = "section_content"
  when /^=== ([^=]+) ===/ then
    goal_title = $1

    if String === goals.last["section_title"] then
      lesson = goals.last
      goals << new_lesson # HACK? I dunno...
    else
      lesson = new_lesson
      goals << lesson
    end

    lesson["goal_title"] = goal_title
    mode = "goal"
  when /^==== Goal ====/ then
    mode = "goal"
  when /^==== Steps ====/ then
    mode = "steps"
  when /^==== What Just Happened\? ====/ then
    mode = "explanation"
  when /^===== / then
    lesson[mode] << line.chomp
  when /^=/ then
    warn "unparsed: #{line.chomp}"
  else
    lesson[mode] << line.chomp
  end
end

goals.each_with_index do |goal, i|
  goal.each do |k,v|
    case v
    when [] then
      goal[k] = nil
    when String then
      # do nothing
    when Array then
      goal[k] = v.join("\n")
    else
      warn "unknown #{v.inspect}"
    end
  end

  warn "no worky: #{i}" unless goal.has_key? "goal_title"

  i += 1
  path = "lessons/%02d.yaml" % i
  File.open path, "w" do |f|
    YAML.dump goal, f
  end
end

# sections = DATA.read.split(/^(== .+)/)
# sections.shift if sections.first.empty?
#
# sections.each_slice(2).each_with_index do |(title, body), i|
#   puts
#   puts "title = #{title}"
#
#   # TODO: prefix section titles with the proper key
#   # TODO: fix step parsing so the step title is captured
#   # TODO: add markdown or something
#   # TODO: add proper level # handling instead of this tripe
#
#   i += 1
#   subsections = body.strip.split(/^(=+ .+)/).map(&:strip)
#   subsections.shift if subsections.first.empty?
#
#   keys = %w[steps section_content goal explanation
#             step_content step_title section_title]
#   lesson = Hash[keys.map { |k| [k, nil] }]
#
#   key_map = {
#     "what just happened?" => "explanation"
#   }
#
#   subsections.each_slice(2) do |(subtitle, content)|
#     key = subtitle.strip_heading.downcase
#     key = key_map[key] || key
#     key = key.gsub(/\W/, '_')
# p key
#     lesson[key] = content
#   end
#
#   path = "lessons/%02d.yaml" % i
#   File.open path, "w" do |f|
#     YAML.dump lesson, f
#   end
# end

__END__
== Meta ==

=== Goal ===

To teach you Ruby on Rails we are setting up a business case for an online voting system. We have requirements that our system should allow users to
* register and login
* view the topics sorted by number of votes
* vote on topics
* create, edit, and destroy topics
Also, we have been told the UI should look like this from our business users:
[[File:Example.jpg]]

Of these requirements, our goal for today is to have a working app online that allows users to manage topics and vote on them. If time allows we can discuss the registration, login, and UI designing aspects of the project.

=== Meta-Goal ===

When you have completed today's goal of getting the basic application online you should understand:
* Basic Ruby syntax
* How to test your Ruby code (irb)
* How to go from requirements to a new working Rails application
* How to get your application online
* The basic tools a RoR developer uses (source control, editor, console, local server)

=== Schedule ===

* 1-ish hour of ruby
* 4-ish hours of rails, broken up in 1-ish hour steps

This is just a rough guideline, not a mandate. Some steps you'll go
over and some you'll go under. It'll all work out by the end of the
day... unless I really screwed something up. :D

=== Format ===

Each lesson will look like this:

<pre>
    == Section Title ==

    === Step Title ===

    ==== Goal ====

    description of the current step

    ==== Steps ====

    * say WHERE the work is being done
    * non-detailed steps to take.

    ==== What Just Happened? ====

    * details of what the steps actually did... spell out the cause and effect.
</pre>

== Introduction to Ruby ==

=== Programming 101 & IRB ===

==== Goal ====

By the end of this section you will:

* be able to start up irb
* do simple calculations in ruby
* use and understand variables
* use and understand collections
* use loops

==== Steps ====

* open up a terminal window and try the following:

<pre>
irb

3 + 3
7 * 6

my_variable = 5

my_variable + 2
my_variable * 3

puts my_variable

fruits = ["kiwi", "strawberry", "plum"]

fruits + ["orange"]
fruits - ["kiwi"]

fruits.each do |f|
  puts f
end

if my_variable > 1 then
  puts "YAY!"
end
</pre>

==== What Just Happened? ====

* irb
** Starts up the '''I'''nteractive '''R'''u'''b'''y Shell an environment where you can try bits of ruby code and they'll be run automatically.
* 3 + 3 and 7 * 6
** Ruby can do simple math automatically.  * is used for multiplication and / for division.
* my_variable = 5
** variables are words that hold information.  Here we're holding a 5 with the words my_variable
* my_variable + 2 and my_variable * 3
** Ruby remembers that we are holding a 5 with the words my_variable and can use that 5 do to math
* puts my_variable
** puts prints the value of what comes after it.  In this case it should print 5 since my_variable is holding a 5
* fruits = ["kiwi", "strawberry", "plum"]
** Variables can also hold more than one value.  Here were using the variable fruits to hold a collection of fruit names.  This type of collection is called an array.
*  fruits + ["orange"] and fruits - ["kiwi"]
** + and - are called operators.  We can use them with the array of fruits just like we can use them with numbers.
* fruits.each do |f|
** This code goes through the fruits array item by item and runs the code between do and end for each item.  These lines should print a list of the fruits.
* if my_variable > 1 then puts foo end
** This prints foo if the value stored in my_variable is greater than 1.  Since the code only runs when certain conditions are met if is called a conditional.

=== Other Tools to help you learn Ruby ===

===== ri =====

ri is a tool to look up ruby documentation:

<pre>
  % ri String.split
  = String.split

  (from ruby core)
  ------------------------------------------------------------------------------
    str.split(pattern=$;, [limit])   => anArray

  ------------------------------------------------------------------------------

  Divides str into substrings based on a delimiter, returning an array of
  these substrings.
  ...
</pre>

You can do a lot with it:

* ri Class -- looks up the class documentation and shows all the methods available.
* ri Class.method -- looks up a specific method on a class or module.
* ri method -- searches all classes for matching methods

If running ri doesn't work and you've installed ruby using rvm, try running this command first:
<pre>
rvm docs generate
</pre>

===== irb =====

We've already introduced irb above, but it can't be stressed enough
that having an interactive live session with ruby is invaluable. You
can learn a lot from it.

Add this to a file called ~/.irbrc:

<pre>
def pim inherited = false
  self.class.public_instance_methods(inherited).sort -
    Object.public_instance_methods
end
</pre>

Now you can do stuff like:

<pre>
  >> "blah".pim
  => ["%", "*", "+", "<<", "<=>", "[]", "[]=", "bytes", "bytesize", "capitalize"...]
</pre>

All of these methods are available for any string. You can then use
`ri` to look up the method documentation.

===== online resources =====

* [http://www.zenspider.com/Languages/Ruby/QuickRef.html Ruby Quickref]
* The Google - searching "ruby" and whatever you're looking for usually leads to good stuff.
* [http://rubykoans.com/  Ruby Koans] - a great set of lessons in an interactive form.
* [http://pine.fm/LearnToProgram/ Learn to Program by Chris Pine] - also available as [http://pragprog.com/book/ltp2/learn-to-program a book]
* [http://pragprog.com/book/ruby3/programming-ruby-1-9 The Pickaxe] - The definitive reference
* [http://en.wikipedia.org/wiki/Why's_(poignant)_Guide_to_Ruby Why's (poignant) Guide to Ruby] - the (crazy) guide to ruby... Try it, you might like it.

== Getting Started ==

# TODO: screenshot

=== Creating Your New Application ===

FIX ME

==== Goal ====

Let's get started. By the end of this step, we'll have a
brand-spankin'-new (empty) rails app.

==== Steps ====

* Open up a terminal window and try out the following.

<pre>
 mkdir railsbridge
 cd railsbridge
 rails new suggestotron
 cd suggestotron
 ls
</pre>

* If you have _any_ problems, contact a TA immediately.

==== What Just Happened? ====

* 'mkdir' stands for make directory (folder).
** We've made a folder called railsbridge
* 'cd' stands for change directory.
** 'cd railsbridge' makes railsbridge our current directory.
* 'rails new' creates a new rails project with the name you give.
** In this case we told it to create a new project called suggestotron.
** We'll go into detail on what it created shortly.
* 'ls' stands for "list (stuff)".
** It shows you the contents of the current folder.

You can see that <code>rails new</code> created a lot directors and
files. The ones we want to focus on today are:

{| border="1" cellspacing="0" cellpadding="3" align="center"
! File/Folder
! Purpose
|-
| app/
| Contains the controllers, models, and views for your application.  You will do most of your work here.
|-
| config/
| Configure your application’s runtime rules, routes, database, and more.
|-
| db/
| Shows your current database schema, as well as the database migrations.
|-
| public/
| The only folder seen to the world as-is.  This is where your images, JavaScript,  stylesheets (CSS), and other static files go
|-
|}

There is a lot more that `rails new` created. Probably enough to fill
a book, so we're going to ignore them for now.

=== Create a new git repo ===

==== Goal ====

In order to publish our application, we need to add our application
and any changes we make over time to a "revision control system". It
our case we're going to use git because it is (relatively) easy and it
is what our app server, heroku, uses to deal with all changes.

==== Steps ====

* In your terminal, try:

<pre>
  git init .
</pre>

==== What Just Happened? ====

It doesn't look like anything really happened, but 'git init'
initialized its repository (repo) in a hidden directory called ".git".
You can see this by typing `ls -a` (list all files).

=== Add the project to the git repo ===

==== Goal ====

The previous step didn't do anything with our application. It is time
to add them to the repo now.

==== Steps ====

* In your terminal, try:

<pre>
git status
git add .
git commit -m "Added all the things"
git status
</pre>

==== What Just Happened? ====

* "git status" tells you everything git sees as modified, new, or missing.
** The first time you run this, you should see a ton of stuff.
** The second time you run this, you shouldn't see much of anything.
* "git add" tells git that you want to add the current directory and everything under it to the repo.
* "git commit" tells git to actually _do_ all things you've said you wanted to do.
** This is done in two steps so you can group multiple changes together.
** '-m "Added all the things"' is just a shortcut to say what your commit message is. You can skip that part and git will bring up an editor to fill out a more detailed message.

=== Deploy to heroku ===

==== Goal ====

OK. We've got an empty app and it has been added to git. What now? '''''Ship it!'''''

==== Steps ====

* In your terminal, try:

<pre>
heroku create
git push heroku master
heroku open
</pre>

==== What Just Happened? ====

* "heroku create" registers a new application on heroku's system.
* "git push" takes all changes you've committed locally and pushes them to heroku.
* "heroku open" opens the new application in your browser.

While I realize that at this point this isn't all that exciting, the
point is that it doesn't get more difficult than this as we add more
functionality to the application. Your typical process will look like:

# Add/change some functionality.
# <code>git commit -m "msg" files</code>
# git push heroku master

# TODO: add my diagram

and boom! Your changes are live!

=== Running Your Application Locally ===

FIX ME

==== Goal ====

Let's fire up the application locally

==== Steps ====

* In your terminal, try this:

<code>
  bundle
  rails server
</code>

Then point your web browser to [http://localhost:3000 http://localhost:3000].

See your web app actually there!

==== What Just Happened? ====

* "bundle" installs software your application needs and prepares it to run.
* "rails server" ran your application locally just like heroku is running it on their servers.
* This provides a very simple means to see your changes before you commit and push them to heroku.

== Topics ==

=== Creating a migration ===

TODO: diagram of topics model

==== Goal ====

The suggestotron has a list of topics that people can vote on. We'll
store our topics in the database. In this step you'll do the
following:

* Create a database table for topics with a title and a description

==== Steps ====

* Open up a terminal window to the suggestotron folder (or use one you already have setup)
* Type the following:

<pre>
rails generate scaffold topic title:string description:text
rake db:migrate
rails server
</pre>

==== What Just Happened? ====

<code>
rails generate scaffold topic title:string description:text
</code>

* <code>generate scaffold</code> tells rails to create everything necessary to get up and running with topics
* <code>topic</code> tells rails the name of the new model
* <code>title:string</code> says that topics have a title, which is a string.
* <code>description:text</code> says that topics have a description which is a "text". We're befuddled by the difference too.
* <code>rake db:migrate</code> tells rails to update the database to include a table for our new model

# TODO: no... we need to show all the files created and say what they mean

=== Explaining MVC and Records ===

[[File:Mvc.jpg]]

TODO: fix fuzzy ugly diagram

==== Goal ====

In this step we'll learn a bit about MVC (Model-View-Controller) architecture.
By the end of this step you should understand the following concepts:

* A record
* Model
* View
* Controller

==== Steps ====

* TODO: have them look at the generated files

==== What Just Happened? ====

Rails implements a very specific notion of the
'''Model-View-Controller''' pattern, which guides how you build a web
application.

'''Model'''

* represents what is in the database
* ActiveRecord, ActiveModel
* TODO: clarify

'''View'''

* the model rendered as HTML
* ActionView, erb
* TODO: clarify

'''Controller'''

* receives HTTP actions (GET, POST, PUT, DELETE)
* decides what to do, such as rendering a view
* ActionController
* TODO: clarify

=== CRUD with Scaffolding ===

==== Goal ====

At the core, most database driven web sites are the same. They need to
store records and provide a way to do the following:

* '''C'''reate new records in the database
* '''R'''ead or show the records in the database
* '''U'''pdate existing records
* '''D'''estroy or delete records

Because these 4 actions (CRUD) are so common rails includes the
scaffold command to make creating them easier.

==== Steps ====

* `rails server`
* Point your browser to [http://localhost:3000/topics http://localhost:3000/topics]
* You should see a page listing topics that looks something like this:

[[File:Seattle_topic_list_page.png]]

* Click on "New Topic"
* Fill in the form to and click "Create Topic"
* You should see a confirmation page like this:

[[File:Seattle_topic_created.png]]

* Click on 'back'
* You should see the topic list again, this time with your new topic listed

[[File:Seattle_list_with_topic.png]]

* Try the 'show', 'edit', and 'destroy' links to see what they do
* You've created a basic database driven web site, congrats!

==== What Just Happened? ====

* How did all those pages get created and hooked together?
** The rails scaffold did it for you.

Let's take a closer look at some of the files rails created:

* app/models/topic.rb
** This file contains code for our topic model.  If you look at it its nearly blank.  Creating, reading, updating, and deleting records is built into rails.
** If you've written HTML before many lines in the views should look familiar.  Rails views are HTML with some extra code added to display data from the database.

* app/views/topics
** This folder contains all the views for our topics model.  This is where the code for the forms you used above is stored.  Rails created all of these pages as part of the scaffold.

* app/views/topics/index.html.erb
** This is the code for the page that lists all the topics.
** Index is the name given to the "default" page for a website or a section of a website.  When you navigate to http://localhost:3000/topics the topics index page is what is sent to your computer.

* app/views/topics/show.html.erb
** This the page you get when you click the "show" link on the "Listing topics" page.

* app/views/topics/new.html.erb
** This is the page you get when you click on "New Topic".

* app/views/topics/edit.html.erb
** This is the page you get when you click on "Edit"

* app/views/topics/_form.html.erb
** You may have noticed that the page for new topics and the page to edit topics looked similar. That's because they both use the code from this file to show a form.  This file is called a partial since it only contains code for part of a page.  Partials always have filenames starting with an underscore character.

* Challenge question: Can you find the line of code in new.html.erb and edit.html.erb that makes the form partial appear?

* app/controllers/topics_controller.rb
** This is the controller file that rails created as part of the scaffold
** If you look you'll see a method (a line beginning with <code>def</code>) for each of the views listed above (except _form.html.erb)

=== Commit and push to heroku ===

==== Goal ====

We just added a whole new feature. Let's push it to heroku so our
friends can play with it.

==== Steps ====

In your terminal, try:  ('''note:''' there is a period after the word add in the first line)

<pre>
git add .
git commit -m "Added topics"
git push heroku master
heroku rake db:migrate
</pre>

==== What Just Happened? ====

* We've done the first three steps before, so we won't go over that again...
* `heroku rake` executes a rake task on your server, in this case, `db:migrate`, just like you did locally.

== Voting on Topics ==

TODO diagram

=== Creating a model for votes ===

==== Goal ====

* Create another database table to track votes

==== Steps ====

* In a terminal window type the following

<pre>
rails generate resource vote topic_id:integer
rake db:migrate
</pre>

==== What Just Happened? ====

* Just like before, we're creating a new model named "vote"
* The only thing really different is the integer we added called topic_id.
** topic_id is the data we need to draw the line between votes and topics.
* We didn't generate a full scaffold this time because we aren't going to do the full CRUD for votes, they're just going to be considered part of topics as-is.

=== Hooking up votes and topics ===

==== Goal ====

* Build the relationship between votes and topics

==== Steps ====

* Edit app/models/topic.rb so that it looks like this:

<pre>
class Topic < ActiveRecord::Base
  has_many :votes
end
</pre>

TODO: add cascading deletes?

* Edit app/models/vote.rb so that it looks like this:

<pre>
class Vote < ActiveRecord::Base
  belongs_to :topic
end
</pre>

==== What Just Happened? ====

* has_many and belongs_to:
** In rails, relationships between models are called associations
** Associations (usually) come in pairs
** A topic will have many votes so we put 'has_many :votes' in the topic model.
*** When you ask a topic for its votes, you get an array of votes for that topic.
** A vote is for a particular topic, so we put 'belongs_to :topic' in the vote model.
*** When you ask a vote for its topic, you get the topic for that vote.

=== Allow people to vote ===

==== Goal ====

* Add a button to vote on the topic list page

==== Steps ====

* Edit app/views/topics/index.html.erb so that the bottom loop looks like this:

<pre>
<% @topics.each do |topic| %>
  <tr>
    <td><%= topic.title %></td>
    <td><%= topic.description %></td>
    <td><%= pluralize(topic.votes.length, "vote") %></td>
    <td><%= link_to '+1', votes_path(:topic_id => topic.id), :method => :post %></td>
    <td><%= link_to 'Show', topic %></td>
    <td><%= link_to 'Edit', edit_topic_path(topic) %></td>
    <td><%= link_to 'Destroy', topic, :confirm => 'Are you sure?', :method => :delete %></td>
  </tr>
<% end %>
</pre>

* Add the following method to Vote in app/controllers/votes_controller.rb:

<pre>
def create
  topic = Topic.find(params[:topic_id])
  vote = topic.votes.build
  vote.save!
  redirect_to(topics_path)
end
</pre>

* Go back to [http://localhost:3000/topics http://localhost:3000/topics] and play.
* Revel in the fact that you didn't have to restart the server to see these changes. Hawt, no?

==== What Just Happened? ====

First we added this line to app/views/topics/index.html.erb

<pre>
<td><%= link_to '+1', votes_path(:topic_id => topic.id), :method => :post %></td>
</pre>

* `link_to '+1'` creates an html link with the text '+1'
* `votes_path(:topic_id => topic.id)` creates the right url for the action we want to invoke. In this case, we want to create a vote for the current topic.
** `votes_path(:topic_id => 42)` would output `/votes?topic_id=42`
* `:method => :post` ensures we do the create action of CRUD, not the read action.

The changes we made to votes controller are a bit more complicated so
let's work through them line by line

* topic = Topic.find(params[:topic_id])
** Finds the topic in the database with that id and stores it in the variable 'topic'.
** params[:topic_id] corresponds to the topic_id part of the votes_path above (eg `?topic_id=42`).
* `vote = topic.votes.build` creates a new vote for the current topic.
* `vote.save!` saves the vote to the database.
* `redirect_to(topics_path)` tells the browser to go back to topics_path (the topics list).

=== Commit and push to heroku ===

==== Goal ====

We just made some awesome changes. Let's push them so our friends can
play with it.

==== Steps ====

In your handy-dandy terminal, try:

<pre>
% git add .
% git commit -m "Added votes"
% git push heroku master
% heroku rake db:migrate
</pre>

==== What Just Happened? ====

Again with the pushing and the remote migration... By this time it
should be fairly old hat.

== Flow ==

=== Setting the default page ===

==== Goal ====

Currently when you go to http://localhost:3000 you see the "Welcome aboard" message.

It would be easier to use our app if http://localhost:3000 went directly to the topics list.

In this step we'll make that happen and learn a bit about routes in rails.

==== Steps ====

* open config/routes.rb
* Near the end of the file but before the final end add <code>root :to => 'topics#index'</code>.  When you are done the last few lines should look like this:

<pre>
  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'

  root :to => 'topics#index'
end
</pre>

* You also need to remove the welcome aboard page for the new route to work.  Type this in a terminal window:

<pre>
git rm public/index.html
</pre>

* Go back to [http://localhost:3000/ http://localhost:3000/].  You should be taken to the topics list automatically.

==== What Just Happened? ====

* root :to => 'topics#index' is a rails route that says the default address for your site is topics#index.  topics#index is the topics list page (the topics controller with the index action).

* Rails routes control how URLs (web addresses) get matched with code on the server.   Similar to how addresses match with houses and apartments.
* The file config/routes.rb is like an address directory listing the possible addresses and which code goes with each one
* routes.rb uses some shortcuts so it doesn't always show all the possible URLs.  To explore the URLs in more detail  we can use the terminal.

* At the terminal type <pre> rake routes</pre> you should get something that looks like this:
<pre>
     votes GET    /votes(.:format)           {:action=>"index", :controller=>"votes"}
           POST   /votes(.:format)           {:action=>"create", :controller=>"votes"}
  new_vote GET    /votes/new(.:format)       {:action=>"new", :controller=>"votes"}
 edit_vote GET    /votes/:id/edit(.:format)  {:action=>"edit", :controller=>"votes"}
      vote GET    /votes/:id(.:format)       {:action=>"show", :controller=>"votes"}
           PUT    /votes/:id(.:format)       {:action=>"update", :controller=>"votes"}
           DELETE /votes/:id(.:format)       {:action=>"destroy", :controller=>"votes"}
    topics GET    /topics(.:format)          {:action=>"index", :controller=>"topics"}
           POST   /topics(.:format)          {:action=>"create", :controller=>"topics"}
 new_topic GET    /topics/new(.:format)      {:action=>"new", :controller=>"topics"}
edit_topic GET    /topics/:id/edit(.:format) {:action=>"edit", :controller=>"topics"}
     topic GET    /topics/:id(.:format)      {:action=>"show", :controller=>"topics"}
           PUT    /topics/:id(.:format)      {:action=>"update", :controller=>"topics"}
           DELETE /topics/:id(.:format)      {:action=>"destroy", :controller=>"topics"}
      root        /                          {:action=>"index", :controller=>"topics"}
</pre>

* This shows all the URLs your application responds to.
* The code that starts with colons are variables so :id means the id number of the record.
* The code in parenthesis is optional

TODO: diagram the routes

===== Exploring Routes (optional) =====

Open up your rails console:

<pre>
  rails console
</pre>

Now you can have a look at the paths that are available in your app.
Let's try looking at one of the topics routes we just generated.

<pre>
 app.topics_path
 => "/topics"
 app.topics_url
 => "http://www.example.com/topics"
</pre>

=== Redirect to the topics list after creating a new topic ===

==== Goal ====

When a user creates a new topic they are currently shown a page with
just that topic. For our voting app it makes more sense that they
would be taken back to the topic list.

In this step we'll change the flow of our app so that the user is
taken back to the topics list after they add a new topic.

==== Steps ====

* Open app/controllers/topics_controller.rb
* Look at the create method (it looks like this):

<pre>
  def create
    @topic = Topic.new(params[:topic])

    respond_to do |format|
      if @topic.save
        format.html { redirect_to @topic, :notice => 'Topic was successfully created.' }
        format.json { render :json => @topic, :status => :created, :location => @topic }
      else
        format.html { render :action => "new" }
        format.json { render :json => @topic.errors, :status => :unprocessable_entity }
      end
    end
  end
</pre>

* Change the line "format.html { redirect_to topics_path, :notice => 'Topic was successfully created.' }" so that the file looks like this:

<pre>
  def create
    @topic = Topic.new(params[:topic])

    respond_to do |format|
      if @topic.save
        format.html { redirect_to topics_path, :notice => 'Topic was successfully created.' }
        format.json { render :json => @topic, :status => :created, :location => @topic }
      else
        format.html { render :action => "new" }
        format.json { render :json => @topic.errors, :status => :unprocessable_entity }
      end
    end
  end
</pre>

* Try it out [http://localhost:3000 http://localhost:3000]

==== What Just Happened? ====

* <pre> format.html { redirect_to topics_path, :notice => 'Topic was successfully created.' }</pre>
** format.html means that the server should send html back to the browser
** redirect_to topics_path means show the topics list page when we're done creating a topic
** :notice => 'Topic was successfully created.' puts the message into the flash so it will be displayed on the topics list

=== Make the topic title a link ===

==== Goal ====

Our customer has requested two changes for our site:

* Don't show the description on the list page
* Make the title a link and when its clicked show the description

==== Steps ====

* Let's start by removing the description
* Open app/views/topics/index.html.erb

* Delete the line that looks like this:

<pre>
<td><%= topic.description %></td>
</pre>

* Also delete the line that looks like this:

<pre>
<th>Description</th>
</pre>

* If you save and try to load it in the browser you should see that the description no longer appears
* Now to make the title a link
* In app/views/topics/index.html.erb again replace this line:

<pre>
<td><%= topic.title %></td>
</pre>

with this

<pre>
<td><%= link_to topic.title, topic %></td>
</pre>

==== What Just Happened? ====

* TODO

=== Clean up links on the topics list ===

==== Goal ====

Our app is nearly done. The main topics listing page is pretty busy.
There are a lot of links that aren't necessary.

Let's clean up the topics list page by doing the following:

* Remove the 'show' link
* Remove the 'edit' link
* Change 'destroy' to 'delete'

==== Steps ====

* Open app/views/topics/index.html.erb
* Remove these two lines:

<pre>
<td><%= link_to 'Show', topic %></td>
<td><%= link_to 'Edit', edit_topic_path(topic) %></td>
</pre>

* Change the line with the word 'Destroy' to this

<pre>
<td><%= link_to 'Delete', topic, :confirm => 'Are you sure?', :method => :delete %></td>
</pre>

* Save your file and try reloading in your browser to see the changes.

==== What Just Happened? ====

* TODO

=== Commit and push to heroku ===

* TODO
