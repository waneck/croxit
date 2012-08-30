#include <hx/CFFI.h>

extern "C" 
{
	extern AutoGCRoot *ngap_global_event_handler;
	extern AutoGCRoot *ngap_activate_event_handler;
	
	value ngap_dispatch_event(value name, value args);
	
}

