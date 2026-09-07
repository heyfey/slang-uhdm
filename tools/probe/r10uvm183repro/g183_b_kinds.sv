// r10uvm183 grid ARM B — THE DECLARED-KIND AXIS inside a WILDCARD CLONE.
// uvm170's law was FENCED by a type-kind row nobody predicted, so this arm
// asks the same question of this face: does the clone's degrade depend on what
// the iterated array is DECLARED as?  Eight kinds, one `foreach` each, all in
// free functions of one home package that a wildcard importer clones.
package kb183;
  typedef enum bit [1:0] { LO0 = 0, MID1 = 1, HI2 = 2 } lvl_e;
  typedef struct packed { bit [7:0] hi; bit [7:0] lo; } pair_t;
  typedef int quad_t[4];

  function automatic int k_str(string sq[$]);           // string queue formal
    k_str = 0;
    foreach (sq[a1]) k_str++;
  endfunction

  function automatic int k_int();                       // fixed int local
    int fixed_five[5];
    k_int = 0;
    foreach (fixed_five[b2]) k_int += fixed_five[b2];
  endfunction

  function automatic int k_enum();                      // dynamic enum local
    lvl_e steps[];
    k_enum = 0;
    steps = new[3];
    foreach (steps[c3]) k_enum++;
  endfunction

  function automatic int k_struct();                    // packed-struct queue
    pair_t duos[$];
    k_struct = 0;
    foreach (duos[d4]) k_struct += duos[d4].lo;
  endfunction

  function automatic int k_alias();                     // typedef'd array type
    quad_t four_up;
    k_alias = 0;
    foreach (four_up[e5]) k_alias += four_up[e5];
  endfunction

  function automatic int k_assoc_s();                   // associative [string]
    int by_word[string];
    k_assoc_s = 0;
    by_word["zz"] = 9;
    foreach (by_word[f6]) k_assoc_s += by_word[f6];
  endfunction

  function automatic int k_assoc_i();                   // associative [int]
    bit by_num[int];
    k_assoc_i = 0;
    by_num[7] = 1;
    foreach (by_num[g7]) k_assoc_i++;
  endfunction

  function automatic int k_two_d();                     // two dimensions
    bit [3:0] grid_it[2][3];
    k_two_d = 0;
    foreach (grid_it[h8, i9]) k_two_d += grid_it[h8][i9];
  endfunction
endpackage

package kwild183;
  import kb183::*;
  function automatic int pull_all();
    string sq[$];
    sq.push_back("q");
    return k_str(sq) + k_int() + k_enum() + k_struct() + k_alias() +
           k_assoc_s() + k_assoc_i() + k_two_d();
  endfunction
endpackage

module kb_top183;
  import kwild183::*;
  int total9;
  initial total9 = pull_all();
endmodule
