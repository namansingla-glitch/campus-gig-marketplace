package com.gigmarket.gigs;

import java.util.Locale;
import java.util.UUID;

/**
 * Portfolio uploads are stored under a fresh random name with the original's (allowed) extension only.
 * The name the browser sends is never used as a path, so "../../x" cannot write outside the upload folder.
 */
public final class Uploads {
    /** PDF or image. */
    public static final String[] ALLOWED = {"pdf", "png", "jpg", "jpeg", "webp"};

    private Uploads() {}

    /** A safe stored file name, or null when the extension is not allowed. */
    public static String storedName(String submitted) {
        if (submitted == null) return null;
        String base = submitted.replace('\\', '/');
        base = base.substring(base.lastIndexOf('/') + 1);
        int dot = base.lastIndexOf('.');
        if (dot < 0 || dot == base.length() - 1) return null;
        String ext = base.substring(dot + 1).toLowerCase(Locale.ROOT);
        for (String ok : ALLOWED) {
            if (ok.equals(ext)) return UUID.randomUUID() + "." + ext;
        }
        return null;
    }
}
