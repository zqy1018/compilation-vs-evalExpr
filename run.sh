make_pair() {
  local s="$1"
  printf '(true, %s)' "$s"
}

choose_number() {
  local s="$1"
  if [[ "$s" == "small" ]]; then
    printf '%s' "998244353"
  else
    printf '%s' "6306436948373"
  fi
}

make_call() {
  local a="$1"
  local b="$2"
  case "$a" in
    0) printf "foo true %s" "$b" ;;
    1) printf "foo' true %s" "$b" ;;
    2) printf "isPrime %s" "$b" ;;
    3) printf "isPrimeUsingClass true %s" "$b" ;;
    4) printf "isPrimeNotUsingClass true %s" "$b" ;;
    *) return 1 ;;
  esac
}

lake build mini
mkdir -p output

# main1, only provide arguments
for j in {0..4}
do
    for size in large small
    do
        num=$(choose_number ${size})
        input=$(make_pair ${num})
        output="output/output-main1-mode${j}-${size}-byarg.txt"
        lake exe mini 1 ${j} <<< "${input}" &> ${output}
    done
done

# main1, provide the complete function call
for j in {0..4}
do
    for size in large small
    do
        num=$(choose_number ${size})
        input=$(make_call ${j} ${num})
        output="output/output-main1-mode${j}-${size}-bycall.txt"
        lake exe mini 1 ${j} <<< "${input}" &> ${output}
    done
done

# main2
for j in {0..4}
do
    for size in large small
    do
        num=$(choose_number ${size})
        output="output/output-main2-mode${j}-${size}.txt"
        lake exe mini 2 ${j} ${num} &> ${output}
    done
done

# list all files mentioning "Stack overflow detected."
grep -lF 'Stack overflow detected.' output/* 2>/dev/null
