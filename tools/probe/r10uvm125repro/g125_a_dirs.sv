// r10uvm125 arm A — output/inout/ref formals, matching vs converting actual types.
package pk125a;
  typedef bit [63:0] wide_t;
  typedef bit [31:0] narrow_t;

  function int fsame(input int p, output wide_t v);
    v = 64'd1; return p;
  endfunction

  function int fconv(input int p, output wide_t v);
    v = 64'd2; return p;
  endfunction

  function int finout(input int p, inout wide_t v);
    v = v + 1; return p;
  endfunction

  function automatic int fref(input int p, ref wide_t v);
    v = v + 2; return p;
  endfunction

  task tconv(output wide_t v);
    v = 64'd3;
  endtask

  class C125;
    int ok;
    function void run();
      wide_t   w;
      narrow_t n;
      int      i;
      // 1. output, SAME type as formal -> no conversion
      ok = fsame(1, w);
      // 2. output, NARROWER actual -> implicit conversion on the copy-back
      ok = fconv(2, n);
      // 3. output, int actual
      ok = fconv(3, i);
      // 4. compound-assign statement wrapping the call (the UVM shape)
      ok &= fconv(4, n);
      // 5. inout, converting
      n = 32'd7;
      ok = finout(5, n);
      // 6. ref, converting is illegal; ref with same type
      ok = fref(6, w);
      // 8. bare statement call, converting output
      void'(fconv(8, n));
    endfunction
    task runt();
      narrow_t n;
      // 7. TASK call, converting output arg
      tconv(n);
    endtask
  endclass
endpackage
