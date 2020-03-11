#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include "FacebookAdsEx.h"

using namespace facebookadsex;

AutoGCRoot* adsEventHandle = 0;

#ifdef IPHONE

static void ads_set_event_handle(value onEvent)
{
    adsEventHandle = new AutoGCRoot(onEvent);
}
DEFINE_PRIM(ads_set_event_handle, 1);

static value facebookadsex_init(value rewarded_id, value testing_ads){
	init(val_string(rewarded_id), val_bool(testing_ads));
	return alloc_null();
}
DEFINE_PRIM(facebookadsex_init,2);

static value facebookadsex_show_rewarded(){
	showRewarded();
	return alloc_null();
}
DEFINE_PRIM(facebookadsex_show_rewarded,0);


#endif

extern "C" void facebookadsex_main () {	
	val_int(0); // Fix Neko init
	
}
DEFINE_ENTRY_POINT (facebookadsex_main);

extern "C" int facebookadsex_register_prims () { return 0; }

extern "C" void sendAdsEvent(const char* type)
{
    printf("Send Event: %s\n", type);
    value o = alloc_empty_object();
    alloc_field(o,val_id("type"),alloc_string(type));
    val_call1(adsEventHandle->get(), o);
}