// r10uvm42 arm t59a — THE ARRAY-ELEMENT / ASSOC-INDEX TWIN WITNESS.
//
// § arrayElemTdClone42 says a VECTOR typedef reached THROUGH A CONTAINER (an
// unpacked array's ELEMENT typespec, an associative array's INDEX typespec)
// gets a PER-DECLARATION NAMED CLONE that aliases the view's listing object,
// never the listing object itself.  It was decoded on the UVM corpus, where
// the typedef is PACKAGE-homed; the reach measurement (the byte verifier saw
// only the 4 UVM tests move) leaves the obvious question unanswered, so this
// arm carries BOTH spellings of the typedef's home:
//
//   * a PACKAGE vector typedef (`pkc::w8`), the decoded half, and
//   * a MODULE-scope vector typedef (`mw8`), the UNMEASURED half — a law that
//     only ever saw one spelling has an unmeasured half (pass 41's own guard
//     needed BOTH registries for exactly this reason),
//
// each used in every container position the arm can reach:
//   fixed unpacked array, dynamic array, queue, associative-by-typedef-name,
//   as a class PROPERTY and as a subroutine BODY LOCAL, plus plain scalar
//   declarations that must not move.
//
// What to read in the golden: for each typedef, the LISTING object's name and
// the name/span of whatever each container position points at.  `r10uvm42tw`
// prints exactly that, including which references reach the listing object.
package pkc;

  typedef bit [7:0] w8;        // the package vector typedef

  w8 pkgscalar;                // plain user — must stay as it is

  class holder;
    w8  cfix[4];               // class property, fixed unpacked array
    w8  cdyn[];                // ...dynamic
    w8  cq[$];                 // ...queue
    int cmap[w8];              // ...associative, index = the typedef NAME
    extern function void body();
    extern function int  formals(w8 f, w8 fa[], int fm[w8]);
  endclass

  function void holder::body();
    w8  lfix[4];               // body local, fixed unpacked array
    w8  ldyn[];
    w8  lq[$];
    int lmap[w8];
    w8  lscalar;
    lfix[0] = 8'h1;
    ldyn = new[2];
    lq.push_back(8'h2);
    lmap[8'h3] = 1;
    lscalar = 8'h4;
  endfunction

  function int holder::formals(w8 f, w8 fa[], int fm[w8]);
    return int'(f);
  endfunction

  // a free package function, so the DEF listing is exercised as well as the
  // class methods (the two views bind different listing objects)
  function w8 pkgfn(w8 a);
    w8  ffix[4];
    int fmap[w8];
    ffix[0] = a;
    fmap[a] = 1;
    return ffix[0];
  endfunction

endpackage

module dut59;
  import pkc::*;

  typedef bit [7:0] mw8;       // the MODULE-scope vector typedef

  mw8 mscalar;                 // plain user
  mw8 mfix[4];                 // module-level fixed unpacked array
  mw8 mdyn[];
  mw8 mq[$];
  int mmap[mw8];               // module-level associative, index = alias

  // the package typedef, used from a MODULE (the elaborated listing's view)
  w8  pfix[4];
  int pmap[w8];

  function void mfn();
    mw8 lfix[4];
    int lmap[mw8];
    mw8 lscalar;
    lfix[0] = 8'h5;
    lmap[8'h6] = 2;
    lscalar = 8'h7;
  endfunction

  initial begin
    mscalar = 8'h1;
    mfix[0] = 8'h2;
    mdyn = new[2];
    mq.push_back(8'h3);
    mmap[8'h4] = 1;
    pfix[0] = 8'h5;
    pmap[8'h6] = 2;
    mfn();
  end
endmodule
