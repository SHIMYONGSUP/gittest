unit hmx.define;

interface

uses
    hmx.constant;
type
    {$I hmx.define.rtv.inc}
    {$I hmx.define.rgc.inc}
    {$I hmx.define.shm.inc}
var
	shmptr : ^SHMEM_INFO;

implementation

end.

