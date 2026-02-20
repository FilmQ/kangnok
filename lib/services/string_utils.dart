class StringUtils {
  // Suffixes to strip when deriving Storage folder names from park names
  static const _parkSuffixes = [' National Park'];

  /// Derives the Storage folder name from a park name.
  /// e.g. "Doi Inthanon National Park" -> "doi_inthanon"
  /// e.g. "Kasetsart University"       -> "kasetsart_university"
  static String storageFolderName(String parkName) {
    var stripped = parkName;
    for (final suffix in _parkSuffixes) {
      if (stripped.endsWith(suffix)) {
        stripped = stripped.substring(0, stripped.length - suffix.length);
        break;
      }
    }
    return stripped.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
  }

  /// Normalizes a name for lookup matching: lowercase, spaces/hyphens to underscores.
  static String normalizeForLookup(String name) {
    return name.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
  }
}

void main() {
  print(StringUtils.normalizeForLookup("Lady's Finger Orchid"));
}
