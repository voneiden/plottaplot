from django.shortcuts import render
from django.shortcuts import render_to_response, redirect, HttpResponse, Http404
from django.template import RequestContext
import json

# Create your views here.
def index(request):
    #return HttpResponse(json.dumps({}), content_type='application/json')
    context = RequestContext(request, {
        'foo': 'bar',
        'faa': 'zomg',
        })

    return render_to_response('interface/index.html', context)

    #response = render_to_response('dashboard/review.html', context)
    #return HttpResponse(json.dumps(annotated_dict), content_type='application/json')
    #raise Http404