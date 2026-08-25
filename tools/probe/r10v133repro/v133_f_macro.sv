// r10v133 arm F - the FIELD-AUTOMATION macro shape of the corpus head, over
// four container faces, reached through TWO class instances.  MEASUREMENT ONLY.
`define VF133_CMP(ARG) \
  if ($bits(ARG.size()) <= 64) begin \
    rv = rv + 1; \
  end else begin \
    rv = rv + 2; \
  end
`define VF133_BODY(NAME) \
  function void NAME``_do133(); \
    `VF133_CMP(fq) \
    `VF133_CMP(fs) \
    `VF133_CMP(fd) \
    `VF133_CMP(fa) \
  endfunction

package pv133f;
  class fld133_c;
    string fq[$];
    string fs[$];
    int    fd[];
    int    fa[string];
    int    rv;
    `VF133_BODY(one)
    `VF133_BODY(two)
  endclass

  class use133_c;
    fld133_c h1;
    fld133_c h2;
    function void run133();
      h1 = new();
      h2 = new();
      h1.one_do133();
      h2.two_do133();
    endfunction
  endclass
endpackage
