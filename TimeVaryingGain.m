function yout = TimeVaryingGain(rng_loss,ref_loss,x)

range_loss = rng_loss(:)-ref_loss;
normal_vector = db2mag(range_loss);
normal_vector = normal_vector(1:size(x,1));
yout = zeros(size(x,1),size(x,2));
for i = 1:size(x,2)
    for j = 1:size(x,1)
        yout(j,i) = x(j, i) * normal_vector(j,1);
    end
end
