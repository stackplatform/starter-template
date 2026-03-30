class BuildMock {
    static function main() {
        if (!sys.FileSystem.exists('dist')) {
            sys.FileSystem.createDirectory('dist');
        }
        var arg = Sys.args()[0];
        if (arg == null) arg = "unknown";
        
        // Create a minimal valid ZIP file (empty archive, 22 bytes)
        // This is just the End of Central Directory record
        var buf = new haxe.io.BytesBuffer();
        buf.addByte(0x50); buf.addByte(0x4b); buf.addByte(0x05); buf.addByte(0x06); // End of Central Directory signature
        buf.addByte(0x00); buf.addByte(0x00); // Disk number
        buf.addByte(0x00); buf.addByte(0x00); // Start disk
        buf.addByte(0x00); buf.addByte(0x00); // Entries on disk
        buf.addByte(0x00); buf.addByte(0x00); // Total entries
        buf.addByte(0x00); buf.addByte(0x00); buf.addByte(0x00); buf.addByte(0x00); // Central directory size
        buf.addByte(0x00); buf.addByte(0x00); buf.addByte(0x00); buf.addByte(0x00); // Central directory offset
        buf.addByte(0x00); buf.addByte(0x00); // Comment length
        
        sys.io.File.saveBytes('dist/server-' + arg + '-x64.zip', buf.getBytes());
        Sys.println('Mock build for ' + arg + ' complete.');
    }
}
