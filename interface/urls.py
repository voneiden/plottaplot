__author__ = 'wizard'
from django.conf.urls import patterns, url, include

urlpatterns = patterns('',
                       url(r'^$', 'interface.views.index', name="index"),
                       )