# -*- coding: utf-8 -*-
import hashlib
import time

class Module:

    def __init__(self, queue, config):
        self.queue = queue
        self.url_reg = str(config.get("url_reg", ""))
        self.url_log1 = str(config.get("url_log1", ""))        
        
    def GetPartner(self):
        return 'ad2de'
    
    def Install(self, events):
        events.OnFirstLogin.Bind(self.OnFirstLogin) 
        events.OnCastleLogin.Bind(self.OnCastleLogin)    
        
    def OnFirstLogin(self, user): 
        if int(user.cregs) == 1:
            url = self.url_reg % (str(user.auid))
            self.queue.Push(url)

    def OnCastleLogin(self, user, faction, auid):
        if int(user.clogins) == 1:
            url = self.url_log1 % (str(user.puid),str(auid))
            self.queue.Push(url)                   