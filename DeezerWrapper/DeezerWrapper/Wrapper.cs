using DeezerWrapper;
using Newtonsoft.Json;
using System;
using System.Collections;
using System.Runtime.InteropServices;
using System.Windows.Threading;
// make this binding dependent on WPF, but easier to use

// http://www.codeproject.com/Articles/339290/PInvoke-pointer-safety-Replacing-IntPtr-with-unsaf

namespace Deezer
{

    #region Enums

    public enum STREAMING_MODE
    {
        DZ_STREAMING_MODE_UNKNOWN,  /**< Mode is not known or audio ad is playing. */
        DZ_STREAMING_MODE_ONDEMAND, /**< On demand streaming mode. */
        DZ_STREAMING_MODE_RADIO,    /**< Radio streaming mode. */
    }

    public enum CONNECT_EVENT_TYPE
    {
        UNKNOWN,                           /**< Connect event has not been set yet, not a valid value. */
        USER_OFFLINE_AVAILABLE,            /**< User logged in, and credentials from offline store are loaded. */

        USER_ACCESS_TOKEN_OK,              /**< (Not available) dz_connect_login_with_email() ok, and access_token is available */
        USER_ACCESS_TOKEN_FAILED,          /**< (Not available) dz_connect_login_with_email() failed */

        USER_LOGIN_OK,                     /**< Login with access_token ok, infos from user available. */
        USER_LOGIN_FAIL_NETWORK_ERROR,     /**< Login with access_token failed because of network condition. */
        USER_LOGIN_FAIL_BAD_CREDENTIALS,   /**< Login with access_token failed because of bad credentials. */
        USER_LOGIN_FAIL_USER_INFO,         /**< Login with access_token failed because of other problem. */
        USER_LOGIN_FAIL_OFFLINE_MODE,      /**< Login with access_token failed because we are in forced offline mode. */

        USER_NEW_OPTIONS,                  /**< User options have just changed. */

        ADVERTISEMENT_START,               /**< A new advertisement needs to be displayed. */
        ADVERTISEMENT_STOP,                /**< An advertisement needs to be stopped. */
    };

    public enum ERRORS
    {
        DZ_ERROR_NO_ERROR = 0x00000000,
        DZ_ERROR_NO_ERROR_ASYNC = 0x00000001,
        DZ_ERROR_ERROR_ARG = 0x00000002,
        DZ_ERROR_ERROR_STATE = 0x00000003,
        DZ_ERROR_NOT_IMPLEMENTED = 0x00000004,
        DZ_ERROR_ASYNC_CANCELED = 0x00000005,

        DZ_ERROR_NOT_ENOUGH_MEMORY,
        DZ_ERROR_OS_ERROR,
        DZ_ERROR_UNSUPPORTED,
        DZ_ERROR_CLASS_NOT_FOUND,
        DZ_ERROR_JSON_PARSING,
        DZ_ERROR_XML_PARSING,
        DZ_ERROR_PARSING,
        DZ_ERROR_CLASS_INSTANTIATION,
        DZ_ERROR_RUNNABLE_ALREADY_STARTED,
        DZ_ERROR_RUNNABLE_NOT_STARTED,
        DZ_ERROR_CACHE_RESOURCE_OPEN_FAILED,
        DZ_ERROR_FS_FULL,
        DZ_ERROR_FILE_EXISTS,
        DZ_ERROR_IO_ERROR,

        DZ_ERROR_CATEGORY_CONNECT = 0x00010000,
        DZ_ERROR_CONNECT_SESSION_LOGIN_FAILED,
        DZ_ERROR_USER_PROFILE_PERM_DENIED,
        DZ_ERROR_CACHE_DIRECTORY_PERM_DENIED,
        DZ_ERROR_CONNECT_SESSION_NOT_ONLINE,
        DZ_ERROR_CONNECT_SESSION_OFFLINE_MODE,
        DZ_ERROR_CONNECT_NO_OFFLINE_CACHE,

        DZ_ERROR_CATEGORY_PLAYER = 0x00020000,
        DZ_ERROR_PLAYER_PLAYLIST_NONE_SET,
        DZ_ERROR_PLAYER_PLAYLIST_BAD_INDEX,
        DZ_ERROR_PLAYER_PLAYLIST_NO_MEDIA,         /**< when trying to access non existing track/radio */
        DZ_ERROR_PLAYER_PLAYLIST_NO_RIGHTS,        /**< when trying to access track/radio with no rights */
        DZ_ERROR_PLAYER_PLAYLIST_RIGHT_TIMEOUT,    /**< when timoeout trying to get rights */
        DZ_ERROR_PLAYER_PLAYLIST_RADIO_TOO_MANY_SKIP,
        DZ_ERROR_PLAYER_PLAYLIST_NO_MORE_TRACK,
        DZ_ERROR_PLAYER_PAUSE_NOT_STARTED,
        DZ_ERROR_PLAYER_PAUSE_ALREADY_PAUSED,
        DZ_ERROR_PLAYER_UNPAUSE_NOT_STARTED,
        DZ_ERROR_PLAYER_UNPAUSE_NOT_PAUSED,
        DZ_ERROR_PLAYER_SEEK_NOT_SEEKABLE_NOT_STARTED,
        DZ_ERROR_PLAYER_SEEK_NOT_SEEKABLE_NO_DURATION,
        DZ_ERROR_PLAYER_SEEK_NOT_SEEKABLE_NOT_INDEXED,
        DZ_ERROR_PLAYER_SEEK_NOT_SEEKABLE,

        DZ_ERROR_CATEGORY_MEDIASTREAMER = 0x00030000,
        DZ_ERROR_MEDIASTREAMER_BAD_URL_SCHEME,
        DZ_ERROR_MEDIASTREAMER_BAD_URL_HOST,
        DZ_ERROR_MEDIASTREAMER_BAD_URL_TRACK,
        DZ_ERROR_MEDIASTREAMER_NOT_AVAILABLE_OFFLINE,
        DZ_ERROR_MEDIASTREAMER_NOT_READABLE,
        DZ_ERROR_MEDIASTREAMER_NO_DURATION,
        DZ_ERROR_MEDIASTREAMER_NOT_INDEXED,
        DZ_ERROR_MEDIASTREAMER_SEEK_NOT_SEEKABLE,
        DZ_ERROR_MEDIASTREAMER_NO_DATA,
        DZ_ERROR_MEDIASTREAMER_END_OF_STREAM,
        DZ_ERROR_MEDIASTREAMER_ALREADY_MAPPED,
        DZ_ERROR_MEDIASTREAMER_NOT_MAPPED,

        DZ_ERROR_CATEGORY_OFFLINE = 0x00040000,
        DZ_ERROR_OFFLINE_FS_FULL,

        DZ_ERROR_PLAYER_BAD_URL,
    };

    public enum PLAYER_COMMANDS
    {
        UNKNOWN,           /**< Player command has not been set yet, not a valid value. */
        START_TRACKLIST,   /**< A new tracklist was loaded and a track played. */
        JUMP_IN_TRACKLIST, /**< The user jump into a new song in the current tracklist. */
        NEXT,              /**< Next button. */
        PREV,              /**< Prev button. */
        DISLIKE,           /**< Dislike button. */
        NATURAL_END,       /**< Natural end. */
        RESUMED_AFTER_ADS, /**< Reload after playing an ads. */
    }

    public enum TRACKLIST_AUTOPLAY_MODE
    {
        DZ_INDEX_IN_QUEUELIST_INVALID = -1,

        DZ_INDEX_IN_QUEUELIST_PREVIOUS = -2,

        DZ_INDEX_IN_QUEUELIST_CURRENT = -3,

        DZ_INDEX_IN_QUEUELIST_NEXT = -4,        
    };

    public enum PLAYER_EVENT_TYPE
    {
        DZ_PLAYER_EVENT_UNKNOWN,                             /**< Player event has not been set yet, not a valid value. */

        // Data access related event.
        DZ_PLAYER_EVENT_LIMITATION_FORCED_PAUSE,             /**< Another deezer player session was created elsewhere, the player has entered pause mode. */

        // Track selection related event.
        DZ_PLAYER_EVENT_QUEUELIST_LOADED,                    /**< Content has been loaded. */
        DZ_PLAYER_EVENT_QUEUELIST_NO_RIGHT,                  /**< You don't have the right to play this content: track, album or playlist */
        DZ_PLAYER_EVENT_QUEUELIST_TRACK_NOT_AVAILABLE_OFFLINE,/**< You're offline, the track is not available. */
        DZ_PLAYER_EVENT_QUEUELIST_TRACK_RIGHTS_AFTER_AUDIOADS,/**< You have right to play it, but you should render an ads first :
                                                              - Use dz_player_event_get_advertisement_infos_json().
                                                              - Play an ad with dz_player_play_audioads().
                                                              - Wait for #DZ_PLAYER_EVENT_RENDER_TRACK_END.
                                                              - Use dz_player_play() with previous track or DZ_PLAYER_PLAY_CMD_RESUMED_AFTER_ADS (to be done even on mixes for now).
                                                          */
        DZ_PLAYER_EVENT_QUEUELIST_SKIP_NO_RIGHT,              /**< You're on a mix, and you had no right to do skip. */

        DZ_PLAYER_EVENT_QUEUELIST_TRACK_SELECTED,             /**< A track is selected among the ones available on the server, and will be fetched and read. */

        DZ_PLAYER_EVENT_QUEUELIST_NEED_NATURAL_NEXT,          /**< We need a new natural_next action. */

        // Data loading related event.
        DZ_PLAYER_EVENT_MEDIASTREAM_DATA_READY,              /**< Data is ready to be introduced into audio output (first data after a play). */
        DZ_PLAYER_EVENT_MEDIASTREAM_DATA_READY_AFTER_SEEK,   /**< Data is ready to be introduced into audio output (first data after a seek). */

        // Play (audio rendering on output) related event.
        DZ_PLAYER_EVENT_RENDER_TRACK_START_FAILURE,       /**< Error, track is unable to play. */
        DZ_PLAYER_EVENT_RENDER_TRACK_START,               /**< A track has started to play. */
        DZ_PLAYER_EVENT_RENDER_TRACK_END,                 /**< A track has stopped because the stream has ended. */
        DZ_PLAYER_EVENT_RENDER_TRACK_PAUSED,              /**< Currently on paused. */
        DZ_PLAYER_EVENT_RENDER_TRACK_SEEKING,             /**< Waiting for new data on seek. */
        DZ_PLAYER_EVENT_RENDER_TRACK_UNDERFLOW,           /**< Underflow happened whilst playing a track. */
        DZ_PLAYER_EVENT_RENDER_TRACK_RESUMED,             /**< Player resumed play after a underflow or a pause. */
        DZ_PLAYER_EVENT_RENDER_TRACK_REMOVED,             /**< Player stopped playing a track. */
    };

    public enum QUEUELIST_REPEAT_MODE
    {
        DZ_QUEUELIST_REPEAT_MODE_OFF,          /**< Play the loaded content starting from the given track index in the queuelist. */
        DZ_QUEUELIST_REPEAT_MODE_ONE,          /**< Automatically play the current track forever. */
        DZ_QUEUELIST_REPEAT_MODE_ALL,          /**< Automatically play the entire queuelist forever with a natural order. */
    }

    #endregion

    #region Delegates

    // called with userdata Dispatcher on connect events
    public delegate void ConnectOnEventCb(Connect connect, ConnectEvent connectEvent, DispatcherObject userdata);
    public delegate void PlayerOnEventCb(Player player, PlayerEvent playerEvent, DispatcherObject userdata);

    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    unsafe public delegate void libcConnectOnEventCb(CONNECT* libcConnect, CONNECT_EVENT* libcConnectEvent, IntPtr userdata);
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    unsafe public delegate bool libcAppCrashDelegate();
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    unsafe public delegate void libcPlayerOnEventCb(PLAYER* libcPlayer, PLAYER_EVENT* libcPlayerEvent, IntPtr userdata);

    #endregion

    #region Structures

    unsafe public struct CONNECT_EVENT { };

    unsafe public struct UTF8STRING { };

    unsafe public struct CONNECT { };

    unsafe public struct PLAYER_EVENT { };

    unsafe public struct PLAYER { };

    #endregion

    #region Imports

    #endregion

    // to be in sync with dz_connect_configuration
    [StructLayout(LayoutKind.Sequential)]
    public class ConnectConfig
    {
        public string ccAppId;

        public string product_id;
        public string product_build_id;
        public string anonymousblob;


        //public string ccAppSecret;

        public string ccUserProfilePath;

        public DispatcherObject ccConnectUserdata;
        public ConnectOnEventCb ccConnectEventCb;
    }

    public class ConnectEvent
    {
        internal CONNECT_EVENT_TYPE eventType;

        /* two design strategies:
     * - we could keep a reference to CONNECT_EVENT* with dz_object_retain and call method on the fly
     * - we extract all info in constructor and have pure managed object
     * 
     * here we keep the second option, because we have to have a managed object anyway, and it's 
     * a lot fewer unsafe method to expose, even though it's making a lot of calls in the constructor..
     */
        public unsafe static ConnectEvent newFromLibcEvent(CONNECT_EVENT* libcConnectEventHndl)
        {
            CONNECT_EVENT_TYPE eventType;
            unsafe
            {
                eventType = dz_connect_event_get_type(libcConnectEventHndl);
            }
            switch (eventType)
            {
                case CONNECT_EVENT_TYPE.USER_ACCESS_TOKEN_OK:
                    string accessToken;
                    unsafe
                    {
                        IntPtr libcAccessTokenString = dz_connect_event_get_access_token(libcConnectEventHndl);
                        accessToken = Marshal.PtrToStringAnsi(libcAccessTokenString);
                    }
                    return new NewAccessTokenConnectEvent(accessToken);
                default:
                    return new ConnectEvent(eventType);
            }
        }

        public ConnectEvent(CONNECT_EVENT_TYPE eventType)
        {
            this.eventType = eventType;
        }

        public CONNECT_EVENT_TYPE GetEventType()
        {
            return eventType;
        }

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe CONNECT_EVENT_TYPE dz_connect_event_get_type(CONNECT_EVENT* dzConnectEvent);

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe IntPtr dz_connect_event_get_access_token(CONNECT_EVENT* dzConnectEvent);
    }

    public class NewAccessTokenConnectEvent : ConnectEvent
    {
        string accessToken;

        public NewAccessTokenConnectEvent(string accessToken)
        : base(CONNECT_EVENT_TYPE.USER_ACCESS_TOKEN_OK)
        {
            this.accessToken = accessToken;
        }

        public string GetAccessToken()
        {
            return accessToken;
        }
    }

    unsafe public class Connect : IDisposable
    {
        // hash
        static Hashtable refKeeper = new Hashtable();

        internal unsafe CONNECT* libcConnectHndl;
        internal ConnectConfig connectConfig;

        public unsafe Connect(ConnectConfig cc)
        {
            NativeMethods.LoadClass();
            //ConsoleHelper.AllocConsole();
            // attach a console to parent process (launch from cmd.exe)
            //ConsoleHelper.AttachConsole(-1);

            CONNECT_CONFIG libcCc = new CONNECT_CONFIG();

            connectConfig = cc;

            IntPtr intptr = new IntPtr(this.GetHashCode());

            refKeeper[intptr] = this;

            libcCc.ccAppId = cc.ccAppId;
            libcCc.ccAnonymousBlob = cc.anonymousblob;
            //libcCc.ccAppSecret = cc.ccAppSecret;
            libcCc.ccProductBuildId = cc.product_build_id;
            libcCc.ccProductId = cc.product_id;
            libcCc.ccUserProfilePath = UTF8Marshaler.GetInstance(null).MarshalManagedToNative(cc.ccUserProfilePath);
            libcCc.ccConnectEventCb = delegate (CONNECT* libcConnect, CONNECT_EVENT* libcConnectEvent, IntPtr userdata)
            {
                Connect connect = (Connect)refKeeper[userdata];
                ConnectEvent connectEvent = ConnectEvent.newFromLibcEvent(libcConnectEvent);
                DispatcherObject dispather = connect.connectConfig.ccConnectUserdata;

                if (dispather != null)
                    dispather.Dispatcher.Invoke(connect.connectConfig.ccConnectEventCb, connect, connectEvent, connect.connectConfig.ccConnectUserdata);
                else
                    connect.connectConfig.ccConnectEventCb.Invoke(connect, connectEvent, connect.connectConfig.ccConnectUserdata);
            };

            libcConnectHndl = dz_connect_new(libcCc);

            UTF8Marshaler.GetInstance(null).CleanUpNativeData(libcCc.ccUserProfilePath);
            
        }

        public int Start()
        {
            int ret;
            ret = dz_connect_activate(libcConnectHndl, new IntPtr(this.GetHashCode()));
            return ret;
        }

        public string DeviceId()
        {
            IntPtr libcDeviceId = dz_connect_get_device_id(libcConnectHndl);

            if (libcDeviceId == null)
            {
                return null;
            }

            return Marshal.PtrToStringAnsi(libcDeviceId);
        }

        public int SetAccessToken(string accessToken)
        {
            int ret;
            ret = dz_connect_set_access_token(libcConnectHndl, IntPtr.Zero, IntPtr.Zero, accessToken);
            return ret;
        }

        public int SetSmartCache(string path, int quotaKb)
        {
            int ret;
            ret = dz_connect_cache_path_set(libcConnectHndl, IntPtr.Zero, IntPtr.Zero, path);
            ret = dz_connect_smartcache_quota_set(libcConnectHndl, IntPtr.Zero, IntPtr.Zero, quotaKb);
            return ret;
        }

        public int ConnectOfflineMode()
        {
            int ret;
            ret = dz_connect_offline_mode(libcConnectHndl, IntPtr.Zero, IntPtr.Zero, false);
            return ret;
        }

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe CONNECT* dz_connect_new(
            [In, MarshalAs(UnmanagedType.LPStruct)]
            CONNECT_CONFIG lpcc);

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe IntPtr dz_connect_get_device_id(
            CONNECT* dzConnect);

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe int dz_connect_activate(
            CONNECT* dzConnect, IntPtr userdata);

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe int dz_connect_set_access_token(
            CONNECT* dzConnect, IntPtr cb, IntPtr userdata, string access_token);

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe int dz_connect_cache_path_set(
            CONNECT* dzConnect, IntPtr cb, IntPtr userdata,
            [MarshalAs(UnmanagedType.CustomMarshaler,
              MarshalTypeRef=typeof(UTF8Marshaler))]
              string local_path);

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe int dz_connect_smartcache_quota_set(
            CONNECT* dzConnect, IntPtr cb, IntPtr userdata,
              int quota_kB);

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe int dz_connect_offline_mode(CONNECT* dzConnect, IntPtr cb, IntPtr userData, bool offlineMode);

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe int dz_player_deactivate(
            CONNECT* dzConnect, IntPtr cb, IntPtr userdata);

        public void Dispose()
        {
            dz_player_deactivate(libcConnectHndl, IntPtr.Zero, IntPtr.Zero);
        }
    }

    public class PlayerEvent
    {
        internal PLAYER_EVENT_TYPE eventType;

        /* two design strategies:
     * - we could keep a reference to PLAYER_EVENT* with dz_object_retain and call method on the fly
     * - we extract all info in constructor and have pure managed object
     * 
     * here we keep the second option, because we have to have a managed object anyway, and it's 
     * a lot fewer unsafe method to expose, even though it's making a lot of calls in the constructor..
     */
        public unsafe static PlayerEvent newFromLibcEvent(PLAYER_EVENT* libcPlayerEventHndl)
        {
            PLAYER_EVENT_TYPE eventType;
            unsafe
            {
                eventType = dz_player_event_get_type(libcPlayerEventHndl);
            }
            switch (eventType)
            {
                default:
                    return new PlayerEvent(eventType);
            }
        }

        public PlayerEvent(PLAYER_EVENT_TYPE eventType)
        {
            this.eventType = eventType;
        }

        public PLAYER_EVENT_TYPE GetEventType()
        {
            return eventType;
        }

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe PLAYER_EVENT_TYPE dz_player_event_get_type(PLAYER_EVENT* dzPlayerEvent);
    }

    unsafe public class Player : IDisposable
    {
        // hash
        static Hashtable refKeeper = new Hashtable();

        internal unsafe PLAYER* libcPlayerHndl;
        internal Connect connect;
        internal libcPlayerOnEventCb eventcb;

        private const int DZ_INDEX_IN_QUEUELIST_INVALID = -1;
        private const int DZ_INDEX_IN_QUEUELIST_PREVIOUS = -2;
        private const int DZ_INDEX_IN_QUEUELIST_CURRENT = -3;
        private const int DZ_INDEX_IN_QUEUELIST_NEXT = -4;

        public unsafe Player(Connect connect, object observer)
        {
            IntPtr intptr = new IntPtr(this.GetHashCode());

            refKeeper[intptr] = this;

            libcPlayerHndl = dz_player_new(connect.libcConnectHndl);

            this.connect = connect;
        }

        public int Start(PlayerOnEventCb eventcb)
        {
            int ret;
            ret = dz_player_activate(libcPlayerHndl, new IntPtr(this.GetHashCode()));

            this.eventcb = delegate (PLAYER* libcPlayer, PLAYER_EVENT* libcPlayerEvent, IntPtr userdata)
            {
                Player player = (Player)refKeeper[userdata];
                PlayerEvent playerEvent = PlayerEvent.newFromLibcEvent(libcPlayerEvent);
                DispatcherObject dispather = player.connect.connectConfig.ccConnectUserdata;

                STREAMING_MODE streamingMode;
                int idx;

                var result = dz_player_event_get_queuelist_context(libcPlayerEvent, &streamingMode, &idx);

                if(!result)
                {
                    streamingMode = STREAMING_MODE.DZ_STREAMING_MODE_ONDEMAND;
                    idx = DZ_INDEX_IN_QUEUELIST_INVALID;
                }

                if(playerEvent.eventType == PLAYER_EVENT_TYPE.DZ_PLAYER_EVENT_QUEUELIST_TRACK_SELECTED)
                {
                    bool isPreview;
                    bool canPauseUnPause;
                    bool canSeek;
                    int numberSkipAllowed;
                    string currentSong;
                    string nextSong;

                    isPreview = dz_player_event_track_selected_is_preview(libcPlayerEvent);
                    var ok = dz_player_event_track_selected_rights(libcPlayerEvent, &canPauseUnPause, &canSeek, &numberSkipAllowed);

                    var songIntPtr = dz_player_event_track_selected_dzapiinfo(libcPlayerEvent);
                    var nextIntPtr = dz_player_event_track_selected_next_track_dzapiinfo(libcPlayerEvent); 

                    currentSong = Marshal.PtrToStringAnsi(songIntPtr);
                    nextSong = Marshal.PtrToStringAnsi(nextIntPtr);

                    var song = JsonConvert.DeserializeObject<Song>(currentSong);

                    Console.WriteLine($"{DateTime.Now} - Artist: {song.artist.name} Song: {song.title} Album: {song.album.title}");
                }

                if (dispather == null)
                    eventcb.Invoke(player, playerEvent, connect.connectConfig.ccConnectUserdata);
                else
                    dispather?.Dispatcher?.Invoke(eventcb, player, playerEvent, connect.connectConfig.ccConnectUserdata);
            };

            ret = dz_player_set_event_cb(libcPlayerHndl, this.eventcb);
            return ret;
        }

        public int LoadStream(string url)
        {
            int ret;
            ret = dz_player_load(libcPlayerHndl, IntPtr.Zero, IntPtr.Zero, url);
            return ret;
        }

        public int Play()
        {
            int ret;
            ret = dz_player_play(libcPlayerHndl, IntPtr.Zero, IntPtr.Zero, PLAYER_COMMANDS.START_TRACKLIST, DZ_INDEX_IN_QUEUELIST_CURRENT);            
            return ret;
        }

        public int Next()
        {
            int ret;
            ret = dz_player_play(libcPlayerHndl, IntPtr.Zero, IntPtr.Zero, PLAYER_COMMANDS.START_TRACKLIST, DZ_INDEX_IN_QUEUELIST_NEXT);
            return ret;
        }

        public int Previous()
        {
            int ret;
            ret = dz_player_play(libcPlayerHndl, IntPtr.Zero, IntPtr.Zero, PLAYER_COMMANDS.START_TRACKLIST, DZ_INDEX_IN_QUEUELIST_PREVIOUS);
            return ret;
        }

        public int Pause()
        {
            int ret;
            ret = dz_player_pause(libcPlayerHndl, IntPtr.Zero, IntPtr.Zero);
            return ret;
        }

        public int Resume()
        {
            int ret;
            ret = dz_player_resume(libcPlayerHndl, IntPtr.Zero, IntPtr.Zero);
            return ret;
        }

        public int SetRepeatMode(QUEUELIST_REPEAT_MODE repeatMode)
        {
            int ret;
            ret = dz_player_set_repeat_mode(libcPlayerHndl, IntPtr.Zero, IntPtr.Zero, repeatMode);
            return ret;
        }

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe PLAYER* dz_player_new(CONNECT* lpcc);        

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe int dz_player_set_event_cb(PLAYER* lpcc, libcPlayerOnEventCb cb);

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe int dz_player_activate(PLAYER* dzPlayer, IntPtr userdata);        

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe int dz_player_load(PLAYER* dzPlayer, IntPtr cb, IntPtr userdata, string url);

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe int dz_player_play(PLAYER* dzPlayer, IntPtr cb, IntPtr userdata, PLAYER_COMMANDS cmd, int mode);

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe bool dz_player_event_get_queuelist_context(PLAYER_EVENT* eventHendle, STREAMING_MODE* streamingMode, int* out_idx);

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe bool dz_player_event_track_selected_is_preview(PLAYER_EVENT* eventHandle);

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe bool dz_player_event_track_selected_rights(PLAYER_EVENT* eventHandle, bool* canPauseUnpause, bool* canSeek, int* numseek);

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode)]
        static extern unsafe IntPtr dz_player_event_track_selected_dzapiinfo(PLAYER_EVENT* eventHandle);

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe IntPtr dz_player_event_track_selected_next_track_dzapiinfo(PLAYER_EVENT* eventHandle);

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe int dz_player_pause(PLAYER* dzplayer, IntPtr cb, IntPtr userData);

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe int dz_player_resume(PLAYER* dzplayer, IntPtr cb, IntPtr userData);

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe int dz_player_set_repeat_mode(PLAYER* dzplayer, IntPtr cb, IntPtr userData, QUEUELIST_REPEAT_MODE mode);

        [DllImport("libdeezer.x86.dll", CallingConvention = CallingConvention.Cdecl)]
        static extern unsafe int dz_player_deactivate(PLAYER* dzplayer, IntPtr cb, IntPtr userData);

        public void Dispose()
        {
            dz_player_deactivate(libcPlayerHndl, IntPtr.Zero, IntPtr.Zero);
        }
    }

    [StructLayout(LayoutKind.Sequential)]
    public class CONNECT_CONFIG
    {
        public string ccAppId;

        public string ccProductId;
        public string ccProductBuildId;

        public IntPtr ccUserProfilePath;

        public libcConnectOnEventCb ccConnectEventCb;

        public string ccAnonymousBlob;

        public libcAppCrashDelegate ccAppCrashDelegate;

    }




    // trick from http://stackoverflow.com/questions/1573724/cpu-architecture-independent-p-invoke-can-the-dllname-or-path-be-dynamic
    // but actually SetDllDirectory works better (for pthread.dll)
    public static class NativeMethods
    {
        // call this to load this class
        public static void LoadClass()
        {
        }

        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool SetDllDirectory(string lpPathName);

        [DllImport("kernel32", SetLastError = true, CharSet = CharSet.Unicode)]
        static extern IntPtr LoadLibrary(string lpFileName);

        static NativeMethods()
        {
            string arch;
            string basePath = System.IO.Path.GetDirectoryName(typeof(NativeMethods).Assembly.Location);

            if (IntPtr.Size == 4)
                arch = "i386";
            else
                arch = "x86_64";

            System.Diagnostics.Debug.WriteLine("using arch: " + arch);

            SetDllDirectory(System.IO.Path.Combine(basePath, arch));
#if false // can be used to debug library loading
        IntPtr hExe = LoadLibrary("libdeezer.x86.dll");

        if (hExe == IntPtr.Zero)
        {
            Win32Exception ex = new Win32Exception(Marshal.GetLastWin32Error());
            System.Console.WriteLine("exception:" + ex);
            throw ex;
        }
#endif
        }

    }

    // http://stackoverflow.com/questions/10415807/output-console-writeline-from-wpf-windows-applications-to-actual-console
    public class ConsoleHelper
    {
        /// <summary>
        /// Allocates a new console for current process.
        /// </summary>
        [DllImport("kernel32.dll")]
        public static extern Boolean AllocConsole();

        [DllImport("Kernel32.dll")]
        public static extern bool AttachConsole(int processId);

        /// <summary>
        /// Frees the console.
        /// </summary>
        [DllImport("kernel32.dll")]
        public static extern Boolean FreeConsole();
    }

    // http://www.codeproject.com/Articles/138614/Advanced-Topics-in-PInvoke-String-Marshaling
    public class UTF8Marshaler : ICustomMarshaler
    {
        static UTF8Marshaler static_instance;

        // maybe we could play with WideCharToMultiByte too and avoid Marshal.Copy
        // http://stackoverflow.com/questions/537573/how-to-get-intptr-from-byte-in-c-sharp
        /*
        Byte[] byNewData = null;

        iNewDataLen = NativeMethods.WideCharToMultiByte(NativeMethods.CP_UTF8, 0, cc.ccUserProfilePath, -1, null, 0, IntPtr.Zero, IntPtr.Zero);
        Console.WriteLine("iNewDataLen:" + iNewDataLen + " len:" + cc.ccUserProfilePath.Length + " ulen:" + iNewDataLen);
        byNewData = new Byte[iNewDataLen];
        iNewDataLen = NativeMethods.WideCharToMultiByte(NativeMethods.CP_UTF8, 0, cc.ccUserProfilePath, cc.ccUserProfilePath.Length, byNewData, iNewDataLen, IntPtr.Zero, IntPtr.Zero);

        libcCc.ccUserProfilePath = Marshal.UnsafeAddrOfPinnedArrayElement(byNewData, 0);
     */
        public IntPtr MarshalManagedToNative(object managedObj)
        {
            if (managedObj == null)
                return IntPtr.Zero;
            if (!(managedObj is string))
                throw new MarshalDirectiveException(
                       "UTF8Marshaler must be used on a string.");

            // not null terminated
            byte[] strbuf = System.Text.Encoding.UTF8.GetBytes((string)managedObj);
            IntPtr buffer = Marshal.AllocHGlobal(strbuf.Length + 1);
            Marshal.Copy(strbuf, 0, buffer, strbuf.Length);

            // write the terminating null
            Marshal.WriteByte(buffer + strbuf.Length, 0);
            return buffer;
        }
        public unsafe object MarshalNativeToManaged(IntPtr pNativeData)
        {
            byte* walk = (byte*)pNativeData;

            // find the end of the string
            while (*walk != 0)
            {
                walk++;
            }
            int length = (int)(walk - (byte*)pNativeData);

            // should not be null terminated
            byte[] strbuf = new byte[length];
            // skip the trailing null
            Marshal.Copy((IntPtr)pNativeData, strbuf, 0, length);
            string data = System.Text.Encoding.UTF8.GetString(strbuf);
            return data;
        }

        public void CleanUpNativeData(IntPtr pNativeData)
        {
            Marshal.FreeHGlobal(pNativeData);
        }

        public void CleanUpManagedData(object managedObj)
        {
        }

        public int GetNativeDataSize()
        {
            return -1;
        }

        public static ICustomMarshaler GetInstance(string cookie)
        {
            if (static_instance == null)
            {
                return static_instance = new UTF8Marshaler();
            }
            return static_instance;
        }

        [DllImport("kernel32.dll")]
        public static extern int WideCharToMultiByte(uint CodePage, uint dwFlags,
           [MarshalAs(UnmanagedType.LPWStr)] string lpWideCharStr, int cchWideChar,
           [MarshalAs(UnmanagedType.LPArray)] Byte[] lpMultiByteStr, int cbMultiByte, IntPtr lpDefaultChar,
           IntPtr lpUsedDefaultChar);

        public const uint CP_UTF8 = 65001;
    }
}
