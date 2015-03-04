# Github Service Webhook for Podio

If you use Podio as a bug tracker this simple web service allows you to close and reference bugs via Git commit messages.

## Usage

This assumes your Bugs app in Podio has a category field called 'Status' which includes a category named 'Fixed'. If this is not the case, you have to adapt the code.

The Webhook will receive all your pushes and searches commit messages on the master branch for text in the form of:

    command #1
    command #1, #2
    command #1 & #2 
    command #1 and #2

Instead of the short-hand syntax "#1", "ticket:1" can be used as well, e.g.:

    command ticket:1
    command ticket:1, ticket:2
    command ticket:1 & ticket:2 
    command ticket:1 and ticket:2

In addition, the ':' character can be omitted and issue or bug can be used instead of ticket.

You can have more than one command in a message. The following commands are supported. There is more than one spelling for each command, to make this as user-friendly as possible.

 * `close`, `closed`, `closes`, `fix`, `fixed`, `fixes`: The specified tickets are set to 'Fixed' and the commit message is added to them as a comment.
 * `references`, `refs`, `addresses`, `re`, `see`: The specified tickets are left in their current state, and the commit message is added to them as a comment.

A fairly complicated example of what you can do is with a commit message of:

    Changed blah and foo to do this or that. Fixes #10 and #12, and refs #12.

This will close #10 and #12, and add a note to #12.

## Deployment

Register a new Podio API client (https://developers.podio.com/api-key).

Deploy this Sinatra app on one of your servers or on Heroku like this:

``` sh
heroku create my-podio-github
heroku config:set \
  PODIO_CLIENT_ID="REDACTED" \
  PODIO_CLIENT_SECRET="REDACTED"
git push heroku master
```

Configure your Github repository to use the Heroku app as a webhook endpoint.

 * On Podio look up your app id and app token for your Bugs app (Wrench icon -> Developer)
 * On Github go to Settings -> Webhooks & Services -> Add webhook on the repository you want to set up
 * Construct your URL like this: `https://my-podio-github.herokuapp.com/hook?app_id=BUG_APP_ID&app_token=BUG_APP_TOKEN`
 * Add this URL as a WebHook URL on Github with a Content-Type of `application/x-www-form-urlencoded`. Leave the other options in their default state.
 * That should be it.
