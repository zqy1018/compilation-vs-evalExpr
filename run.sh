# main1
for j in {0..4}
do
    for size in large small
    do
        input="input-pair-${size}.txt"
        output="output/output-main1-mode${j}-${size}.txt"
        lake exe mini 1 ${j} < ${input} &> ${output}
    done
done

# main2
for j in {0..4}
do
    for size in large small
    do
        if [ $size == "large" ]
        then
            num=998244353
        else
            num=6306436948373
        fi
        output="output/output-main2-mode${j}-${size}.txt"
        lake exe mini 2 ${j} ${num} &> ${output}
    done
done
