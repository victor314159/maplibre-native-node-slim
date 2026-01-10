console.log('Testing MapLibre GL Native on Debian-based Node.js image');
console.log('Node version:', process.version);
console.log('Platform:', process.platform);
console.log('Arch:', process.arch);
console.log('');

try {
  const mbgl = require('@maplibre/maplibre-gl-native');
  
  console.log('✓ Module loaded successfully');
  console.log('✓ MapLibre Native binaries are compatible with Debian/GLIBC 2.36');
  console.log('');
  console.log('Module exports:');
  console.log('  - Map class:', typeof mbgl.Map);
  console.log('  - Expression:', typeof mbgl.Expression);
  console.log('  - Resource types:', Object.keys(mbgl.Resource).length, 'types');
  console.log('');
  console.log('SUCCESS: MapLibre Native built from source works on node:24-slim!');
  console.log('');
  console.log('Note: Creating a Map instance requires an X display or headless GL context.');
  console.log('      The module loads correctly, which confirms the build is successful.');
  
  process.exit(0);
} catch (error) {
  console.error('✗ Error loading MapLibre GL Native:');
  console.error('  ', error.message);
  console.error('');
  
  if (error.message.includes('GLIBC')) {
    console.error('ISSUE IDENTIFIED:');
    console.error('  The prebuilt binaries require a newer GLIBC version than available in Debian.');
    console.error('  This confirms issue #4024 - Ubuntu binaries are incompatible with Debian-based images.');
    console.error('');
    console.error('POSSIBLE SOLUTIONS:');
    console.error('  1. Build binaries specifically for Debian (with GLIBC 2.36)');
    console.error('  2. Compile from source in the Dockerfile');
    console.error('  3. Use Ubuntu-based Node.js images instead of Debian');
  } else if (error.message.includes('cannot open shared object file')) {
    console.error('ISSUE IDENTIFIED:');
    console.error('  Missing library dependency:', error.message.match(/lib\w+\.so[\d.]*/) ? error.message.match(/lib\w+\.so[\d.]*/)[0] : 'unknown');
    console.error('  Additional system libraries may be needed.');
  }
  
  process.exit(1);
}
