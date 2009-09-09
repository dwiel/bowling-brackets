# -*- coding: utf-8 -*-
import logging

from pylons import request, response, session, tmpl_context as c
from pylons.controllers.util import abort, redirect_to

from bracket.lib.base import BaseController, render

log = logging.getLogger(__name__)

class IndexController(BaseController):

  def index(self):
    c.names = [name.strip() for name in open('names', 'r')]
    return render('/index.mako')

  def create_new_person(self):
    f = open('names', 'a')
    print >>f, request.params['name']
    f.close()
