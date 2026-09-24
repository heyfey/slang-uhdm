// r11u95 a21 -- an UNINSTANTIATED top-level program with a body function and a
// generate-block function: nothing ever elaborates it, so golden's task_funcs
// carry NO vpiInstance.
program prg ();
  function automatic int f_body(); return 3; endfunction
  generate
    if (1) begin : g
      function automatic int f_gen(); return 7; endfunction
    end
  endgenerate
endprogram
