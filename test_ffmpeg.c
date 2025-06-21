#include <stdio.h>
#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libavutil/avutil.h>

int main() {
    printf("FFmpeg version: %s\n", av_version_info());
    printf("libavformat version: %d.%d.%d\n", 
           LIBAVFORMAT_VERSION_MAJOR, 
           LIBAVFORMAT_VERSION_MINOR, 
           LIBAVFORMAT_VERSION_MICRO);
    printf("libavcodec version: %d.%d.%d\n", 
           LIBAVCODEC_VERSION_MAJOR, 
           LIBAVCODEC_VERSION_MINOR, 
           LIBAVCODEC_VERSION_MICRO);
    printf("libavutil version: %d.%d.%d\n", 
           LIBAVUTIL_VERSION_MAJOR, 
           LIBAVUTIL_VERSION_MINOR, 
           LIBAVUTIL_VERSION_MICRO);
    
    printf("FFmpeg for Android build successful!\n");
    return 0;
}
