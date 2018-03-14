#!/bin/sh


if [ "$(echo "@path@" | rev)" != "@htap@" ]; then
    # @path@ becomes a fully defined PATH by default.nix, which
    # makes it hard to dev this script without doing full rebuilds,
    # heh.  so ... do the ol' rev-eroo to avoid the comparison being
    # replaced too.
    PATH="@path@"
fi

cleanup() {
  pushd '/home/grahamc/.mail/grahamc/[Gmail]/.All Mail/cur'

  for uid in `ls | cut -d, -f2 | cut -d: -f1 | sort | uniq -d`; do
      for file in `find . -name '*,'$uid':*' | tail -n+2`; do
          newfile=$(echo $file | sed -e "s/,${uid}:/:/")
          if [ -f $newfile ]; then
             echo "UH OH! File exists: $newfile"
          else
             echo "fixup: ${file} to ${newfile} for UID fixup"
             mv "${file}" "${newfile}"
          fi
      done
  done

  popd
}

set -eux
set -o pipefail

cleanup

notmuch tag -inbox -- "from:codetriage.com or from:pinterest.com"
notmuch tag +ofborg -inbox -- "to:graham+ofborg@grahamc.com"
notmuch tag +gocd -inbox -- "tag:inbox and to:go-cd@googlegroups.com"
notmuch tag +nixpkgs -- "tag:inbox and (to:nix-dev@lists.science.uu.nl or to:nixpkgs@noreply.github.com or to:hydra@noreply.github.com)"
notmuch tag +security -inbox -- "(to:debian-security-announce@lists.debian.org or to:oss-security@lists.openwall.com)"
notmuch tag +draft 'path:[Gmail]/.Drafts/**'
notmuch tag +spam 'path:[Gmail]/.Spam/**'

# USAA Withdrawal or Available Messages
# if they're older than 1 day,
# or have been read
notmuch tag -inbox '
  from:USAA.Customer.Service@mailcenter.usaa.com
    and (
         subject:"withdrawal alert"
      or subject:"available balance"
      or subject:"device preferences were updated"
      or subject:"deposit posted"
    )
  and (
    (date:..1D)
    or (not tag:unread)
  )
'

notmuch tag -inbox '
  (
       (from:nomadphp.com)
    or (from:stackcommerce)
    or (from:linkedin)
    or (from:logentries.com)
    or (from:lobste.rs)
    or (from:matrix.org)
    or (from:quora.com)
    or (from:pnc.com)
    or (from:youtube.com)
    or (from:avangate.com)
    or (from:meetup.com)
    or (from:facebookmail.com)
    or (from:llbean.com)
    or (from:withings.com)
    or (from:drafthouse.com)
    or (from:codepen)
    or (subject:"tech for campaigns")
    or (from:linode.com)
    or (from:mailchimp.com)
    or (from:kickstarter.com)
    or (from:netflix.com)
    or (from:repairclinic.com)
    or (from:aclu.org)
    or (from:fasten.com)
    or (from:exprpt.com)
    or (from:webpass.io)
    or (from:moveon.org)
    or (from:notifications@todoist.com)
    or (from:pool.com subject:"Hotlist for ")
    or (from:"Hydra Build Daemon")
    or (from:"info@optiqueaustin.com")
    or (to:your_activity@noreply.github.com)
    or (to:nixpkgs@noreply.github.com and (not to:mention@noreply.github.com))
    or (to:nix@noreply.github.com and (not to:mention@noreply.github.com))
  )
'

# All the following senders aren't spam, but I don't read them
# regularly
notmuch tag -inbox '
  (
       (from:nytimes.com)
    or (from:kickstarter.com)
  )
  and (
        date:..1D
    or (not tag:unread)
  )

'

notmuch search --output=files "folder:Inbox and not tag:inbox" \
    | (grep -v ".All Mail/cur/" || true) \
    | xargs -n1 -I{} mv {} '/home/grahamc/.mail/grahamc/[Gmail]/.All Mail/cur/'

cleanup

notmuch new --no-hooks
