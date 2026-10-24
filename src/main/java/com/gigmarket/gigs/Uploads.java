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

    /** Stored names look exactly like this: a random UUID and an allowed extension. */
    private static final java.util.regex.Pattern STORED = java.util.regex.Pattern.compile("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\\.(pdf|png|jpg|jpeg|webp)");

    /** The file name part of a stored path when it is one of ours, else null (so a tampered path is never opened). */
    public static String storedFile(String storedPath) {
        if (storedPath == null) return null;
        String name = storedPath.replace('\\', '/');
        name = name.substring(name.lastIndexOf('/') + 1);
        return STORED.matcher(name).matches() ? name : null;
    }

    /** Lower-case extension of a stored path ("pdf"), or null. */
    public static String extension(String storedPath) {
        String name = storedFile(storedPath);
        return name == null ? null : name.substring(name.lastIndexOf('.') + 1);
    }

    /** The response type for a stored extension. */
    public static String contentType(String ext) {
        if ("pdf".equals(ext)) return "application/pdf";
        if ("png".equals(ext)) return "image/png";
        if ("webp".equals(ext)) return "image/webp";
        return "image/jpeg";
    }

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
