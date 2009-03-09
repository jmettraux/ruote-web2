#--
# Copyright (c) 2008-2009, John Mettraux, jmettraux@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++


require 'digest/sha1'


class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  #
  # Used by is_admin?
  #
  ADMIN_GROUP_NAME = 'admins'

  has_many :user_groups, :dependent => :delete_all
  has_many :groups, :through => :user_groups

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message



  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation



  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  #
  # Preventing salt and crypted_password from appearing...
  #
  def to_xml (opts={})

    super(opts.merge(:except => [ :salt, :crypted_password ]))
  end

  #
  # Preventing salt and crypted_password from appearing...
  #
  def to_json (opts={})

    super(opts.merge(:except => [ :salt, :crypted_password ]))
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  #
  # Returns true if the user is member of the administrators group
  #
  def is_admin?

    group_names.include?(ADMIN_GROUP_NAME)
  end

  #
  # Returns true if the user is an administrator ('admin' group) or if the
  # user launched the given process instance
  #
  def is_launcher? (process)

    is_admin? or login == process.variables['launcher']
  end

  #
  # Returns true if user is in the admin group or the user may launch
  # a process instance of the given definition
  #
  def may_launch? (definition)

    return false if definition.is_special?
    is_admin? or (self.groups & definition.groups).size > 0
  end

  #
  # Preventing non-admin users from removing process definitions and
  # preventing admins from removing *embedded* and *untracked*
  #
  def may_remove? (definition)
    return false if definition.is_special?
    is_admin?
  end

  def may_launch_untracked_process?
    self.groups.detect { |g| g.may_launch_untracked_process? }
  end

  def may_launch_embedded_process?
    self.groups.detect { |g| g.may_launch_embedded_process? }
  end

  #--
  # Returns true if the user is in the admin group, or the given workitem
  # is in his 'inbox' or his group inbox
  #
  #def may_edit? (workitem)
  #  (is_admin? or
  #   workitem.store_name == self.login or
  #   self.group_names.include?(workitem.store_name))
  #end
  #++

  #
  # Returns the array of group names the user belongs to.
  #
  def group_names

    groups.collect { |g| g.name }
  end

  #
  # Returns the list of store names this user has access to
  #
  def store_names

    [ system_name, 'unknown' ] + group_names
  end

  #
  # User and Group share this method, which returns login and name respectively
  #
  def system_name

    self.login
  end

  #
  # Returns true if the workitem is in a store the user has access to.
  # (always returns true for an admin).
  #
  def may_see? (workitem)

    is_admin? || store_names.include?(workitem.store_name)
  end

end

