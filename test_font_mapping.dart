void main() {
  final fonts = [
    'Arial',
    'Helvetica Neue',
    'Calibri',
    'Georgia',
    'Times New Roman',
    'Garamond',
    'Inter',
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Poppins',
    'Nunito',
    'Source Sans Pro',
    'Ubuntu',
    'Karla',
    'Quicksand',
    'Comfortaa',
    'Mukti',
    'Oswald',
    'Bebas Neue',
    'Playfair Display',
    'Cinzel',
    'Abril Fatface',
    'Dancing Script',
    'Pacifico',
    'Amatic SC',
    'Great Vibes',
    'Satisfy',
    'Merriweather',
    'Libre Baskerville',
    'Crimson Text',
    'Lora',
    'Vollkorn',
    'Source Serif Pro',
    'PT Serif',
    'Noto Serif',
    'Futura PT',
    'Gothic A1',
    'Rajdhani',
    'Orbitron',
    'Audiowide',
    'Syncopate',
    'Monoton',
    'Rounded Mplus 1c',
    'M PLUS Rounded 1c',
    'Noto Sans JP',
    'Fredoka One',
    'Chewy',
    'Baloo 2',
    'Happy Monkey',
    'Comic Neue',
    'DM Sans',
    'Manrope',
    'Epilogue',
    'Jost',
    'Red Hat Display',
    'Space Grotesk',
    'Syne',
    'Chivo',
    'Press Start 2P',
    'VT323',
    'Special Elite',
    'Courier Prime',
    'Cutive Mono',
    'Nova Mono',
    'Fira Code',
    'JetBrains Mono',
    'Indie Flower',
    'Patrick Hand',
    'Caveat',
    'Shadows Into Light',
    'Sacramento',
    'Marck Script',
    'Parisienne',
    'Tangerine',
  ];

  final mappedFonts =
      fonts.map((font) => font.toLowerCase().replaceAll(' ', '')).toList();

  final supportedFonts = [
    'inter',
    'roboto',
    'opensans',
    'lato',
    'montserrat',
    'poppins',
    'nunito',
    'ubuntu',
    'karla',
    'quicksand',
    'comfortaa',
    'oswald',
    'bebasneue',
    'playfairdisplay',
    'cinzel',
    'dancingscript',
    'pacifico',
    'merriweather',
    'lora',
  ];

  for (var i = 0; i < fonts.length; i++) {
    final original = fonts[i];
    final mapped = mappedFonts[i];
    final isSupported = supportedFonts.contains(mapped);
    // Font mapping check completed
  }

  final unsupported = [];
  for (var i = 0; i < fonts.length; i++) {
    final mapped = mappedFonts[i];
    if (!supportedFonts.contains(mapped)) {
      unsupported.add('${fonts[i]} -> $mapped');
    }
  }

  // Unsupported fonts check completed
  for (var font in unsupported) {
    // Font is unsupported
  }
}
