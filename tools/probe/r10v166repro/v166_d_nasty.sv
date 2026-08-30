// r10v166 ARM D -- the NASTY use sites.  Everything here is legal SV that puts
// the degraded `ref_var` somewhere an emitter path other than the declaration
// has to read it: array methods with a `with` clause, streaming, system
// functions, assignment patterns, loop bodies, virtual/interface classes,
// a class inside an interface, and a bounded queue.
package dn166_pkg;

  class It166;
    int tag;
    function new(int t = 0); tag = t; endfunction
  endclass

  virtual class VBase166;
    typedef It166 vq166_t [$];
    pure virtual function int vsize166();
    function int vlocal166();
      vq166_t vv166;                            // in a VIRTUAL class body
      return vv166.size();
    endfunction
  endclass

  class VImpl166 extends VBase166;
    virtual function int vsize166();
      vq166_t iv166;                            // the BASE's typedef, in an
      return iv166.size();                      // OVERRIDE
    endfunction
  endclass

  class Nasty166;
    typedef It166 nq166_t [$];
    typedef It166 nb166_t [$:7];                // BOUNDED queue
    typedef It166 na166_t [int];
    typedef It166 nf166_t [3];

    // (1) ARRAY METHODS with a `with` clause, and reductions
    function int withCl166();
      nq166_t q166;
      nq166_t r166;
      It166   e0166;
      int     n166;
      e0166 = new(1);
      q166.push_back(e0166);
      r166  = q166.find(e166) with (e166.tag > 0);
      n166  = q166.sum() with (item.tag);
      n166 += q166.size();
      return n166 + r166.size();
    endfunction

    // (2) SYSTEM FUNCTIONS and $display over the degraded local
    function int sysF166();
      nq166_t q166;
      nf166_t f166;
      int     n166;
      n166 = $size(f166) + $dimensions(f166) + $left(f166) + $right(f166);
      $display("%p %0d", q166, q166.size());
      return n166;
    endfunction

    // (3) ASSIGNMENT PATTERN, concatenation and STREAMING
    function int patt166();
      nq166_t q166;
      nf166_t f166;
      It166   a166;
      a166  = new(2);
      f166  = '{a166, a166, a166};
      q166  = {a166, a166};
      q166  = {q166, a166};
      return q166.size() + $size(f166);
    endfunction

    // (4) LOOP BODIES: while / do-while / repeat / forever(+disable)
    task loops166(int n166);
      nq166_t top166;
      int i166;
      i166 = 0;
      while (i166 < n166) begin
        nq166_t wq166;                          // <- degraded in a while body
        wq166 = top166;
        i166++;
      end
      do begin
        nq166_t dq166;                          // <- degraded in a do body
        dq166 = top166;
        i166++;
      end while (i166 < n166);
      repeat (n166) begin
        nq166_t rq166;                          // <- degraded in a repeat body
        rq166 = top166;
      end
      fork
        forever begin
          nq166_t fq166;                        // <- degraded in a forever body
          fq166 = top166;
          #1;
        end
      join_none
    endtask

    // (5) The typedef NAME re-used as a LOCAL VARIABLE name in another method
    function int shadow166();
      int nq166_t;                              // a VARIABLE named like the td
      nq166_t = 3;
      return nq166_t;
    endfunction

    // (6) ASSOCIATIVE traversal with first/next/prev/last/exists/delete
    function int assoc166();
      na166_t a166;
      It166   e1166;
      int     k166;
      int     n166;
      e1166 = new(3);
      a166[3] = e1166;
      if (a166.first(k166)) n166++;
      if (a166.next(k166))  n166++;
      if (a166.last(k166))  n166++;
      if (a166.prev(k166))  n166++;
      if (a166.exists(3))   n166++;
      a166.delete(3);
      return n166 + a166.num();
    endfunction

    // (7) The degraded local as a CLASS-METHOD ARGUMENT default is illegal,
    //     but as an argument to another method it is not.
    function int passon166();
      nq166_t q166;
      return eat166(q166) + q166.size();
    endfunction
    function int eat166(nq166_t arg166);        // a FORMAL, never moved
      return arg166.size();
    endfunction
  endclass

endpackage

// (8) A class inside an INTERFACE, and one inside a MODULE, both with the
//     same shape -- the class home fires wherever the class itself lives.
interface dn166_if;
  import dn166_pkg::*;
  class InIf166;
    typedef It166 fq166_t [$];
    function int f166();
      fq166_t fv166;
      return fv166.size();
    endfunction
  endclass
  InIf166 ii166;
  int r166;
  initial begin
    ii166 = new();
    r166 = ii166.f166();
  end
endinterface

module dn166_top;
  import dn166_pkg::*;
  dn166_if u_if166 ();
  Nasty166 n166;
  VImpl166 v166;
  int r166;
  initial begin
    n166 = new(); v166 = new();
    r166 = n166.withCl166() + n166.sysF166() + n166.patt166()
         + n166.shadow166() + n166.assoc166() + n166.passon166()
         + v166.vsize166() + v166.vlocal166();
    n166.loops166(2);
  end
endmodule
