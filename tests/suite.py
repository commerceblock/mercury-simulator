import pytest
from requests import get


def test_mercury_ping():
	"pequest /ping url from mercury"
	r = get('http://0.0.0.0:18000/ping')
	assert r.status_code == 200
