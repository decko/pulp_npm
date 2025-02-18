import pytest

from urllib.parse import urljoin, urlsplit

from pulp_npm.tests.functional.constants import NPM_FIXTURE_URL


def test_pull_through_install(npm_bindings, npm_remote_factory, npm_distribution_factory, http_get):
    """Test that a pull-through distro can be installed from."""
    remote = npm_remote_factory(url=NPM_FIXTURE_URL)
    distro = npm_distribution_factory(remote=remote.pulp_href)
    PACKAGE = "commander"

    __import__("ipdb").set_trace()
    ye = http_get(f"{distro.base_url}/react")
    # content = npm_bindings.ContentPackagesApi.list(name=PACKAGE)
    # assert content.count == 1
