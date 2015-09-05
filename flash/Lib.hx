package flash;

/* It appears that NMEPreloader references flash.Lib,
 * but not only that, but also somehow gets past the redirection. */
typedef Lib = openfl.Lib;
