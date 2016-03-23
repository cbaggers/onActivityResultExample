using Uno;
using Uno.Graphics;
using Uno.Platform;
using Uno.Collections;
using Fuse;
using Fuse.Controls;
using Fuse.Triggers;
using Fuse.Resources;
using Uno.Compiler.ExportTargetInterop;

public partial class MainView
{
    void ClickPlay(object a1, EventArgs a2)
    {
        Business.Go();
    }
}

[ForeignInclude(Language.Java,
                "android.app.Activity",
                "android.content.Intent",
                "android.net.Uri",
                "android.os.Bundle",
                "android.provider.MediaStore",
                "java.io.File")]
public static extern(android) class Business
{
    static int BAD_ID = 1234;
    static Java.Object _intentListener;
    static Java.Object _file;

    public static void Go()
    {
        if (_intentListener == null)
            _intentListener = Init();
        _file = createImageFile(BAD_ID);
        DoIt(_file);
    }

    [Foreign(Language.Java)]
    static Java.Object Init()
    @{
        com.fuse.Activity.ResultListener l = new com.fuse.Activity.ResultListener() {
            @Override public boolean onResult(int requestCode, int resultCode, android.content.Intent data) {
                return @{OnRecieved(int,int,Java.Object):Call(requestCode, resultCode, data)};
            }
        }
        com.fuse.Activity.subscribeToResults(l);
        return l;
    @}

    static bool OnRecieved(int requestCode, int resultCode, Java.Object data)
    {
        debug_log "yay, got a thing: " + data;

        if (requestCode == BAD_ID)
            debug_log "And it's ours!";

        return (requestCode == BAD_ID);
    }

    [Foreign(Language.Java)]
    static void DoIt(Java.Object _destFile)
    @{
        Activity a = com.fuse.Activity.getRootActivity();
		Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
		Bundle bdl = new Bundle();
		bdl.putParcelable(MediaStore.EXTRA_OUTPUT, Uri.fromFile((File)_destFile));
		takePictureIntent.putExtras(bdl);
        a.startActivityForResult(takePictureIntent, @{BAD_ID});
    @}

    [Foreign(Language.Java)]
    static Java.Object createImageFile(int id)
	@{
		try {
			String fileName = "JPEG_" + id + "_";
			String ext = ".jpg";
			File storageDir = com.fuse.Activity.getRootActivity().getExternalFilesDir(null);
			File photoFile = File.createTempFile(fileName, ext, storageDir);
			return photoFile;
		} catch (Exception ex) {
			return null;
		}
	@}
}

public static extern(!android) class Business
{

    public static void Go()
    {
        debug_log "Wheres mah android?";
    }
}
