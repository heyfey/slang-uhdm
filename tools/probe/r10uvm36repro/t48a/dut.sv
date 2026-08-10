// t48a — pass 36, cell A: WHICH package owns the BARE per-declaration copy
// (LAW S) of an imported package typedef, inside a WILDCARD-IMPORT CLONE body.
//
// The SeqDriver residue is 7 rows of exactly this shape: golden
//   DEFPKG adpcm_pkg::::uvm_integral_to_string io[0] 'value'
//     logic_typespec 'uvm_integral_t' @uvm_pkg!TOP
// where we write @adpcm_pkg.  The clone body lives in the IMPORTING package,
// but the copy names the typedef's HOME package — and, per pass 32's
// § importCopyAggFormalOwnCopy32 note, the ELABORATED (top) view of it, even
// in the importer's DEF listing.
//
// `home48` declares the scalar typedef `w48_t` and a FREE FUNCTION taking it
// as a formal, so a wildcard importer carries a CLONE of that body and the
// copy exists in the importer's DEF *and* ELAB listings — the def/top split
// the t47a class cell could not show (classes hang off top packages only).
//
// TWO importers, anti-sorted against declaration order (`zz48` first, `aa48`
// second), so "the home package" is separated from "the first importer" and
// "the last importer" in one golden.

package home48;
  typedef logic signed [63:0] w48_t;
  typedef int u48_t;
  // free function: every wildcard importer clones this body
  function automatic string w48_to_string(w48_t value);
    return "x";
  endfunction
  // a second one taking the OTHER typedef, to check the law is per-typedef
  function automatic int u48_use(u48_t v);
    return v;
  endfunction
endpackage

// declared FIRST, sorts LAST
package zz48;
  import home48::*;
  function automatic string z48(w48_t value);
    return w48_to_string(value);
  endfunction
endpackage

// declared SECOND, sorts FIRST
package aa48;
  import home48::*;
  function automatic string a48(w48_t value);
    return w48_to_string(value);
  endfunction
endpackage

module mm48;
  import home48::*;
  w48_t s48;
  initial s48 = 64'd0;
endmodule
