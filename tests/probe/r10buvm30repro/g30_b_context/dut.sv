package p30c;
  class c30c;
    int m;
    extern function int oob_plain();
    extern function int oob_in_if(int a);
    extern function int oob_in_begin();
    extern function int oob_cmp();
    extern task oob_task();
    function int inbody_plain();
      return -1;
    endfunction
  endclass

  function int c30c::oob_plain();          // 14
    return -1;                             // 15
  endfunction

  function int c30c::oob_in_if(int a);     // 18
    if (a) return -1;                      // 19
    else return -2;                        // 20
    return -3;                             // 21
  endfunction

  function int c30c::oob_in_begin();       // 24
    begin                                  // 25
      return -1;                           // 26
    end
  endfunction

  function int c30c::oob_cmp();            // 30
    return (m == -1);                      // 31
  endfunction

  task c30c::oob_task();                   // 34
    m = -1;                                // 35
  endtask

  function int pkgfun();                   // 38
    return -1;                             // 39
  endfunction
endpackage

module m30c;                               // 43
  function int modfun();                   // 44
    return -1;                             // 45
  endfunction
  int x;
  initial x = modfun();
endmodule
