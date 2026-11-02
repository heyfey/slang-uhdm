# print task/function headers with whether their own block carries vpiAutomatic:1
/\\_(task|function): / { if (cur!="") print cur, a; match($0,/^ */); ind=RLENGTH; cur=$0; sub(/^ */,"",cur); a=0; next }
cur!="" { match($0,/^ */); if (RLENGTH==ind+2 && $0 ~ /\|vpiAutomatic:1/) a=1; if (RLENGTH<=ind && $0 ~ /\\_|\|vpi/) { print cur, a; cur="" } }
END { if (cur!="") print cur, a }
