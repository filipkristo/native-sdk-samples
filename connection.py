from ctypes import *
libdeezer = cdll.LoadLibrary('libdeezer.so')


class DZConnectConfiguration(Structure):
    _pack_ = 1
    _fields_ = [('app_id', c_char_p),
     ('product_id', c_char_p),
     ('product_build_id', c_char_p),
     ('user_profile_path', c_char_p),
     ('dz_connect_on_event_cb', c_void_p),
     ('anonymous_blob', c_void_p),
     ('dz_connect_crash_reporting_delegate', c_void_p)]


class ConnectionInitFailedError(Exception):

    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr(self.value)


class ConnectionRequestFailedError(Exception):

    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr(self.value)


class ConnectionActivationError(Exception):

    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr(self.value)


class Connection:

    def __init__(self, app_id='', product_id='', product_build_id='', user_profile_path='/var/tmp/dzrcache_NDK_SAMPLE',
                 dz_connect_on_event_cb=None, anonymous_blob=None, dz_connect_crash_reporting_delegate=None):
        self.app_id = app_id
        self.product_id = product_id
        self.product_build_id = product_build_id
        self.user_profile_path = user_profile_path
        self.dz_connect_on_event_cb = dz_connect_on_event_cb
        self.anonymous_blob = anonymous_blob
        self.dz_connect_crash_reporting_delegate = dz_connect_crash_reporting_delegate
        self.connect_handle = 0
        self.active = False
        self._init_handle()

    def _init_handle(self):
        """Initialize connection info and return the connection handler"""
        config = DZConnectConfiguration(c_char_p(self.app_id),
                                        c_char_p(self.product_id),
                                        c_char_p(self.product_build_id),
                                        c_char_p(self.user_profile_path),
                                        c_void_p(self.dz_connect_on_event_cb),
                                        c_void_p(self.anonymous_blob),
                                        c_void_p(self.dz_connect_crash_reporting_delegate))
        self.connect_handle = libdeezer.dz_connect_new(byref(config))
        if not self.connect_handle:
            raise ConnectionInitFailedError('Connection handle failed to initialize. Check connection info you gave.')

    def get_device_id(self):
        return libdeezer.dz_connect_get_device_id(self.connect_handle)

    def debug_log_disable(self):
        if libdeezer.dz_connect_debug_log_disable(self.connect_handle):
            raise ConnectionRequestFailedError('debug_log_disable: Request failed.')

    def activate(self, user_data = None):
        if libdeezer.dz_connect_activate(self.connect_handle, user_data):
            raise ConnectionActivationError('Failed to activate connection. Check your network connection.')
        self.active = True

    def cache_path_set(self, user_cache_path, activity_operation_cb = None, operation_userdata = None):
        if libdeezer.dz_connect_cache_path_set(self.connect_handle, activity_operation_cb, operation_userdata, c_char_p(user_cache_path)):
            raise ConnectionRequestFailedError('cache_path_set: Request failed. Check connection and/or path validity.')

    def set_access_token(self, user_access_token, activity_operation_cb = None, operation_user_data = None):
        if libdeezer.dz_connect_set_access_token(self.connect_handle, activity_operation_cb, operation_user_data, c_char_p(user_access_token)):
            raise ConnectionRequestFailedError('set_access_token: Request failed. Check access token or update it.')

    def connect_offline_mode(self, activity_operation_cb = None, operation_userdata = None, offline_mode_forced = False):
        if libdeezer.dz_connect_offline_mode(self.connect_handle, activity_operation_cb, operation_userdata, c_bool(offline_mode_forced)):
            raise ConnectionRequestFailedError(
                'connect_offline_mode: Request failed. Check connection and callbacks if used.')

    def shutdown(self):
        if self.connect_handle:
            libdeezer.dz_connect_deactivate(self.connect_handle, c_void_p(0), None)
            self.active = False
