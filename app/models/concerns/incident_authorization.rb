# A concern belonging to the Incident model. Methods pertaining to authorization go here.
module IncidentAuthorization
  extend ActiveSupport::Concern

  # A normal user can view his or her own incidents only. An admin user
  # can view non-draft incidents of all users from their ORI.
  def authorized_to_view?(viewing_user)
    if viewing_user.doj?
      # DOJ can view anything
      true
    elsif viewing_user.admin?
      # Admins can view their own incidents, and any non-draft by anyone
      # in their ORI or contract ORIs
      (user == viewing_user) || (!draft? && viewing_user.allowed_oris.include?(ori))
    else
      # Regular user, can only see their own incidents
      user == viewing_user
    end
  end

  def authorized_to_edit?(viewing_user)
    if viewing_user.doj?
      # DOJ can edit anything.
      true
    elsif submitted?
      # After state submission, incidents can no longer be edited.
      false
    elsif viewing_user.admin?
      # Admins can edit unsubmitted incidents that they can view.
      authorized_to_view? viewing_user
    else
      # Regular users can only edit their drafts.
      draft?
    end
  end
end
