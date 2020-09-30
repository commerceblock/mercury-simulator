
import pytest
from requests import get


def test_mercury_ping():
	"pequest /ping url from mercury"
	r = get('http://127.0.0.1:8000/ping')
	assert r.status_code == 200
