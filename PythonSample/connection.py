from ctypes import *

libdeezer = cdll.LoadLibrary('libdeezer.so')

dz_on_event_cb_func = CFUNCTYPE(c_int, c_void_p, c_void_p, c_void_p)
dz_connect_crash_reporting_delegate_func = CFUNCTYPE(c_bool)


class DZConnectConfiguration(Structure):
    """Contains the connection info used by the sdk.

        .. warning:: This is a wrapper the C struct dz_connect_configuration of
        the NativeSDK. Unless you know what you are doing, use the Connection
        class constructor instead since it works as an pythonesque interface
        for this structure.
    """
    _pack_ = 1
    _fields_ = [('app_id', c_char_p),
                ('product_id', c_char_p),
                ('product_build_id', c_char_p),
                ('user_profile_path', c_char_p),
                ('dz_connect_on_event_cb', dz_on_event_cb_func),
                ('anonymous_blob', c_void_p),
                ('dz_connect_crash_reporting_delegate', dz_connect_crash_reporting_delegate_func)]


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


class ConnectionEvent:
    """
        Defines values associated to connection events.
        Use it for your callbacks.
    """
    def __init__(self):
        pass

    (
        UNKNOWN,
        USER_OFFLINE_AVAILABLE,
        USER_ACCESS_TOKEN_OK,
        USER_ACCESS_TOKEN_FAILED,
        USER_LOGIN_OK,
        USER_LOGIN_FAIL_NETWORK_ERROR,
        USER_LOGIN_FAIL_BAD_CREDENTIALS,
        USER_LOGIN_FAIL_USER_INFO,
        USER_LOGIN_FAIL_OFFLINE_MODE,
        USER_NEW_OPTIONS,
        ADVERTISEMENT_START,
        ADVERTISEMENT_STOP
    ) = range(0, 12)


class StreamingMode:
    """Defines values associated to the streaming mode"""
    def __init__(self):
        pass

    (
        UNKNOWN,
        ON_DEMAND,
        RADIO
    ) = range(0, 3)


class Connection:
    """Manage and initiate connection to the API.

        Represents a connection to the API. Stores connection info, event
        callbacks and wrappers to the NativeSDK.

        Attributes:
            app_id                   The ID of the application
            product_id               The name of your application
            product_build_id         The version number
            user_profile_path        The cache path of the user. Deprecated.
            dz_connect_on_event_cb   The event listener to connection operations
            anonymous_blob           Deprecated
            dz_connect_crash_reporting_delegate     The error callback
            active                   True when connection has been activated
            connect_handle           The ID used for all operations initialized
                                     after given connection info
    """
    def __init__(self, app_id='', product_id='', product_build_id='', user_profile_path='/var/tmp/dzrcache_NDK_SAMPLE',
                 dz_connect_on_event_cb=None, anonymous_blob=None, dz_connect_crash_reporting_delegate=None):
        """
        :param app_id: The ID of the application
        :type app_id: str
        :param product_id: The name of your application
        :type product_id: str
        :param product_build_id: The version number
        :type product_build_id: str
        :param user_profile_path: The cache path of the user. Deprecated.
        :type user_profile_path: str
        :param dz_connect_on_event_cb: The event listener to connection operations
        :param anonymous_blob: Deprecated
        :param dz_connect_crash_reporting_delegate: The error callback
        """
        self.app_id = app_id
        self.product_id = product_id
        self.product_build_id = product_build_id
        self.user_profile_path = user_profile_path
        self.dz_connect_on_event_cb = dz_on_event_cb_func(dz_connect_on_event_cb)
        self.anonymous_blob = anonymous_blob
        self.dz_connect_crash_reporting_delegate = dz_connect_crash_reporting_delegate_func(
            dz_connect_crash_reporting_delegate)
        self.connect_handle = 0
        self.active = False

    def init_handle(self):
        """Initialize connection info and return the connection handler

            Build a ConnectionConfiguration objects that wraps
            dz_connect_configuration from the C SDK and fill it with the
            connection instance info. To be called after initializing instance.

            :raises ConnectionInitFailedError when receiving wrong info
        """
        config = DZConnectConfiguration(c_char_p(self.app_id),
                                        c_char_p(self.product_id),
                                        c_char_p(self.product_build_id),
                                        c_char_p(self.user_profile_path),
                                        self.dz_connect_on_event_cb,
                                        c_void_p(self.anonymous_blob),
                                        self.dz_connect_crash_reporting_delegate)
        self.connect_handle = libdeezer.dz_connect_new(byref(config))
        if not self.connect_handle:
            raise ConnectionInitFailedError('Connection handle failed to initialize. Check connection info you gave.')

    # TODO: give the exact type of the callback
    def set_event_callback(self, callback):
        """
        Set the callback that will be triggered anytime connection state changes.

        :param callback: The event callback to give.
        """
        self.dz_connect_on_event_cb = dz_on_event_cb_func(callback)

    def get_device_id(self):
        """
        :return: The device ID for logs
        """
        return libdeezer.dz_connect_get_device_id(self.connect_handle)

    def debug_log_disable(self):
        """
        Mute all API logs for readability's sake

        :raises ConnectionRequestFailedError in case of network problems
        """
        if libdeezer.dz_connect_debug_log_disable(self.connect_handle):
            raise ConnectionRequestFailedError('debug_log_disable: Request failed.')

    # TODO: check user_data use
    def activate(self, user_data=None):
        """
        Launch the connection. To be called after proper initialization of the handle

        :param user_data: A reference to the user's data. Leave blank if not sure.
        """
        if libdeezer.dz_connect_activate(self.connect_handle, c_void_p(user_data)):
            raise ConnectionActivationError('Failed to activate connection. Check your network connection.')
        self.active = True

    # TODO: check activity_operation and operation_userdata use
    def cache_path_set(self, user_cache_path, activity_operation_cb=None, operation_userdata=None):
        """
        Set the cache path for debug purposes and logs.

        :param user_cache_path: The desired path
        :type user_cache_path: str
        :param activity_operation_cb: The callback of the operation.
            Leave blank if unsure.
        :param operation_userdata: Reference to the user data.
            Leave blank if unsure.
        """
        if libdeezer.dz_connect_cache_path_set(self.connect_handle, activity_operation_cb, operation_userdata,
                                               c_char_p(user_cache_path)):
            raise ConnectionRequestFailedError('cache_path_set: Request failed. Check connection and/or path validity.')

    # TODO: check activity_operation and operation_userdata use
    def set_access_token(self, user_access_token, activity_operation_cb=None, operation_user_data=None):
        """
        Set the user access token given by OAuth process.
        Mandatory to allow connection.

        :param user_access_token: The token given by OAuth 2 process.
            Refer to the API documentation.
        :param activity_operation_cb: The callback of the operation.
            Leave blank if unsure.
        :param operation_user_data: Reference to the user data.
            Leave blank if unsure.
        """
        if libdeezer.dz_connect_set_access_token(self.connect_handle, activity_operation_cb, operation_user_data,
                                                 c_char_p(user_access_token)):
            raise ConnectionRequestFailedError('set_access_token: Request failed. Check access token or update it.')

    # TODO: check activity_operation and operation_user_data use
    def connect_offline_mode(self, activity_operation_cb=None, operation_user_data=None, offline_mode_forced=False):
        """
        Force offline mode in lib.

        :param activity_operation_cb: The callback of the operation.
            Leave blank if unsure.
        :param operation_user_data: Reference to the user data.
            Leave blank if unsure.
        :param offline_mode_forced: Force offline mode. Leave to False
            if just to allow connection.
        """
        if libdeezer.dz_connect_offline_mode(self.connect_handle, activity_operation_cb, operation_user_data,
                                             c_bool(offline_mode_forced)):
            raise ConnectionRequestFailedError(
                'connect_offline_mode: Request failed. Check connection and callbacks if used.')

    def shutdown(self):
        """
            Deactivate connection associated to the handle.
        """
        if self.connect_handle:
            libdeezer.dz_connect_deactivate(self.connect_handle, c_void_p(0), None)
            self.active = False
