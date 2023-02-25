class Location():
    def __init__(
        self,
        protocol = None,
        access = None,
        domain = None,
        user = None,
        repo = None,
        branch = None,
        subdirs = None,
    ):
        self.protocol = protocol
        self.access = access
        self.domain = domain
        self.user = user
        self.repo = repo
        self.branch = branch
        self.subdirs = subdirs

    def __eq__(self, other):
        return (
            self.protocol==other.protocol and
            self.access==other.access and
            self.domain==other.domain and
            self.user==other.user and
            self.repo==other.repo and
            self.branch==other.branch and
            self.subdirs==other.subdirs
        )


def ParseLocation(location):
    loc = Location()

    location = location.rstrip('/')

    if ':' not in location:
        left = None
        right = location
    else:
        components = location.split(':')
        left = ':'.join(components[:-1])
        right = components[-1]

    if '/' not in right:
        loc.branch = right
    else:
        components = right.split('/')
        loc.branch = components[0]
        loc.subdirs = components[1:]

    if left is not None:
        left = left.rstrip('/')
        if '://' in left:
            (loc.protocol, left) = left.split('://')
            if '@' in left:
                (loc.access, left) = left.split('@')
        elif '@' in left:
            (loc.protocol, left) = left.split('@')
        components = left.split('/')
        if len(components) > 3:
            raise Exception("More than two '/' not supported!")
        elif len(components) > 2:
            loc.domain = components[0]
            loc.user = components[1]
            loc.repo = components[2]
        else:
            loc.user = components[0]
            loc.repo = components[1]

    return loc
