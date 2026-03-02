public struct FeaturamaStrings {
    public var title: String
    public var filterNew: String
    public var filterPlanned: String
    public var filterInProgress: String
    public var filterDone: String
    public var titlePlaceholder: String
    public var descriptionPlaceholder: String
    public var submit: String
    public var cancel: String
    public var empty: String
    public var emptyHint: String
    public var error: String
    public var retry: String
    public var badgePlanned: String
    public var emailPlaceholder: String
    public var emailEncouragement: String
    public var emailRequired: String
    public var comments: String
    public var commentsCount: String
    public var noComments: String
    public var noCommentsHint: String
    public var commentPlaceholder: String
    public var postComment: String
    public var developerBadge: String
    public var pendingReview: String

    public init(
        title: String = "Feature Requests",
        filterNew: String = "New",
        filterPlanned: String = "Planned",
        filterInProgress: String = "In Progress",
        filterDone: String = "Done",
        titlePlaceholder: String = "Feature title",
        descriptionPlaceholder: String = "Describe the feature...",
        submit: String = "Submit",
        cancel: String = "Cancel",
        empty: String = "No feature requests yet",
        emptyHint: String = "Be the first to suggest a feature!",
        error: String = "Something went wrong",
        retry: String = "Retry",
        badgePlanned: String = "Planned",
        emailPlaceholder: String = "Your email address",
        emailEncouragement: String = "Add your email so we can follow up",
        emailRequired: String = "Email is required",
        comments: String = "Comments",
        commentsCount: String = "{count} comments",
        noComments: String = "No comments yet",
        noCommentsHint: String = "Be the first to share your thoughts",
        commentPlaceholder: String = "Write a comment...",
        postComment: String = "Post",
        developerBadge: String = "Developer",
        pendingReview: String = "Pending Review"
    ) {
        self.title = title
        self.filterNew = filterNew
        self.filterPlanned = filterPlanned
        self.filterInProgress = filterInProgress
        self.filterDone = filterDone
        self.titlePlaceholder = titlePlaceholder
        self.descriptionPlaceholder = descriptionPlaceholder
        self.submit = submit
        self.cancel = cancel
        self.empty = empty
        self.emptyHint = emptyHint
        self.error = error
        self.retry = retry
        self.badgePlanned = badgePlanned
        self.emailPlaceholder = emailPlaceholder
        self.emailEncouragement = emailEncouragement
        self.emailRequired = emailRequired
        self.comments = comments
        self.commentsCount = commentsCount
        self.noComments = noComments
        self.noCommentsHint = noCommentsHint
        self.commentPlaceholder = commentPlaceholder
        self.postComment = postComment
        self.developerBadge = developerBadge
        self.pendingReview = pendingReview
    }
}
