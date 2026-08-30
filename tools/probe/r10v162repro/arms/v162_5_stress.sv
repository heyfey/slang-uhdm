// r10v162 arm 5 — THE RECURSION'S OWN EDGES: the depth bound (16), the paren
// unwrap bound (16), an empty inner concatenation, a zero and a huge
// replication count, a 19- and a 20-digit literal, an underscored literal, a
// sized/based/real literal, and a very wide concatenation.
//
// Legal SV throughout.  The law may ABSTAIN on any of these; what it must not
// do is crash, hang, mint a partial operand vector, or move an accepted twin.
// MEASUREMENT ONLY.
package Deep5_pkg;
  class Rung5;
    function new(string nm = "r"); endfunction
    function string s(); return "s"; endfunction
  endclass

  class Tower5 #(type PEG = int);
    static string log = "";
    string t;
    PEG pg;

    // 18 nested parentheses — past the unwrap bound of 16
    function void d01(); log = {"[", ((((((((((((((((((t)))))))))))))))))), "]", pg.gone()}; endfunction
    // 8 nested parentheses — inside the bound
    function void d02(); log = {"[", ((((((((t)))))))), "]", pg.gone()}; endfunction
    // 20 nested ternaries — past the depth bound of 16
    function void d03(); log = {"[", t=="0"?"a":t=="1"?"a":t=="2"?"a":t=="3"?"a":t=="4"?"a":t=="5"?"a":t=="6"?"a":t=="7"?"a":t=="8"?"a":t=="9"?"a":t=="10"?"a":t=="11"?"a":t=="12"?"a":t=="13"?"a":t=="14"?"a":t=="15"?"a":t=="16"?"a":t=="17"?"a":t=="18"?"a":t=="19"?"a":"z", "]", pg.gone()}; endfunction
    // 6 nested ternaries — inside the bound
    function void d04(); log = {"[", t=="0"?"a":t=="1"?"a":t=="2"?"a":t=="3"?"a":t=="4"?"a":"z", "]", pg.gone()}; endfunction
    // 18 nested concatenations — past the depth bound
    function void d05(); log = {"[", {{{{{{{{{{{{{{{{{{t}}}}}}}}}}}}}}}}}}, "]", pg.gone()}; endfunction
    // 5 nested concatenations — inside the bound
    function void d06(); log = {"[", {{{{{t}}}}}, "]", pg.gone()}; endfunction
    // replication count 0 and 1 and a large one
    function void d07(); log = {"[", {0{t}}, "]", pg.gone()}; endfunction
    function void d08(); log = {"[", {1{t}}, "]", pg.gone()}; endfunction
    function void d09(); log = {"[", {64{t}}, "]", pg.gone()}; endfunction
    // literal faces
    function void d10(); log = {"[", 1234567890123456789, "]", pg.gone()}; endfunction // 19 digits
    function void d11(); log = {"[", 12345678901234567890, "]", pg.gone()}; endfunction // 20 digits
    function void d12(); log = {"[", 1_000, "]", pg.gone()}; endfunction
    function void d13(); log = {"[", 8'd65, "]", pg.gone()}; endfunction
    function void d14(); log = {"[", 32'h0000_00FF, "]", pg.gone()}; endfunction
    function void d15(); log = {"[", t=="" ? 0 : 1, "]", pg.gone()}; endfunction
    // a WIDE concatenation, 24 compound operands
    function void d17(); log = {t=="a"?"1":"0",t=="b"?"1":"0",t=="c"?"1":"0",t=="d"?"1":"0",
                                t=="e"?"1":"0",t=="f"?"1":"0",t=="g"?"1":"0",t=="h"?"1":"0",
                                t=="i"?"1":"0",t=="j"?"1":"0",t=="k"?"1":"0",t=="l"?"1":"0",
                                t=="m"?"1":"0",t=="n"?"1":"0",t=="o"?"1":"0",t=="p"?"1":"0",
                                t=="q"?"1":"0",t=="r"?"1":"0",t=="s"?"1":"0",t=="t"?"1":"0",
                                t=="u"?"1":"0",t=="v"?"1":"0",t=="w"?"1":"0",t=="x"?"1":"0",
                                pg.gone()}; endfunction
    // the ACCEPTED twins for the ones that matter
    function void e01(); log = {"[", ((((((((((((((((((t)))))))))))))))))), "]"}; endfunction
    function void e03(); log = {"[", t=="0"?"a":t=="1"?"a":t=="2"?"a":t=="3"?"a":t=="4"?"a":t=="5"?"a":t=="6"?"a":t=="7"?"a":t=="8"?"a":t=="9"?"a":t=="10"?"a":t=="11"?"a":t=="12"?"a":t=="13"?"a":t=="14"?"a":t=="15"?"a":t=="16"?"a":t=="17"?"a":t=="18"?"a":t=="19"?"a":"z", "]"}; endfunction
    function void e05(); log = {"[", {{{{{{{{{{{{{{{{{{t}}}}}}}}}}}}}}}}}}, "]"}; endfunction
    function void e07(); log = {"[", {0{t}}, "]"}; endfunction
    function void e10(); log = {"[", 1234567890123456789, "]"}; endfunction
    function void e11(); log = {"[", 12345678901234567890, "]"}; endfunction
    function void e12(); log = {"[", 1_000, "]"}; endfunction
    function void e17(); log = {t=="a"?"1":"0",t=="b"?"1":"0",t=="c"?"1":"0",t=="d"?"1":"0",
                                t=="e"?"1":"0",t=="f"?"1":"0",t=="g"?"1":"0",t=="h"?"1":"0"}; endfunction
  endclass
endpackage

module Top_Deep5;
  initial $display("deep5");
endmodule
