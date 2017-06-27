using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DeezerWrapper
{

    public class Song
    {
        public int id { get; set; }
        public bool readable { get; set; }
        public string title { get; set; }
        public string link { get; set; }
        public int duration { get; set; }
        public int rank { get; set; }
        public bool explicit_lyrics { get; set; }
        public Artist artist { get; set; }
        public Album album { get; set; }
        public string type { get; set; }
    }

    public class Artist
    {
        public int id { get; set; }
        public string name { get; set; }
        public string link { get; set; }
        public string picture { get; set; }
        public string tracklist { get; set; }
        public string type { get; set; }
    }

    public class Album
    {
        public int id { get; set; }
        public string title { get; set; }
        public string cover { get; set; }
        public string tracklist { get; set; }
        public string type { get; set; }
    }

}
