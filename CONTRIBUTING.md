Want to contribute? Great! First, read this page (including the small print at the end).

### Before you contribute
Before we can use your code, you must sign the
[Google Individual Contributor License Agreement]
(https://cla.developers.google.com/about/google-individual)
(CLA), which you can do online. The CLA is necessary mainly because you own the
copyright to your changes, even after your contribution becomes part of our
codebase, so we need your permission to use and distribute your code. We also
need to be sure of various other things—for instance that you'll tell us if you
know that your code infringes on other people's patents. You don't have to sign
the CLA until after you've submitted your code for review and a member has
approved it, but you must do it before we can put your code into our codebase.
Before you start working on a larger contribution, you should get in touch with
us first through the issue tracker with your idea so that we can help out and
possibly guide you. Coordinating up front makes it much easier to avoid
frustration later on.

### Code reviews
All submissions, including submissions by project members, require review. We
use Github pull requests for this purpose. We further require Travis CI tests
to pass on your pull request before it can be accepted. Details on how to set
up Travis builds for your pull requests are outlined below.

### Testing pull requests
Testing the notebooks in this repository requires being able to perform API
calls to numerous Google Cloud Platform APIs. When a pull request is based
off of a branch from the main repository Travis is already configured with
the credentials it needs to perform such requests.

However, if you are submitting a pull request from a fork, then you will
need to configure Travis to run on your fork. The steps for doing that are:

1. Create a Google Cloud Platform project to test your changes against. That
   can be done from the Google Cloud Console
   [here](https://console.cloud.google.com/project).
2. Enable billing for your new project.
3. Enable the Cloud Monitoring API for your project.
4. Create a service account under your project (with project editor permission),
   and download the JSON-formatted private key for that account.
5. Go to [Travis CI](https://travis-ci.org) and sign in with your GitHub account.
6. Click on the '+' icon next to the "My Repositories" list and enable Travis
   builds for your fork.
7. Click on the gear icon to edit your travis build, and add two environment
   variables:

    1. "PROJECT_ID", with the value being the ID of the project you created.
    2. "SERVICE_ACCOUNT_KEY", with the value being the contents of the JSON
       key that you downloaded for your service account. Use single quotes
       around your JSON key to ensure that it is treated as a string.

   For both environment variables, keep the "Display value in build log" option
   *DISABLED*. These variables contain sensitive data and you do not want their
   contents being exposed in build logs.

### The small print
Contributions made by corporations are covered by a different agreement than
the one above, the
[Software Grant and Corporate Contributor License Agreement]
(https://cla.developers.google.com/about/google-corporate).
