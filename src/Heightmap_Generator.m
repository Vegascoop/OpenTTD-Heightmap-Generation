function [compiled_heightmap] = Heightmap_Generator(depth,width,sea_level,p,q,iterations,decay_fun,mask_type,mask_modifier)

%p is the spikiness (0-10) q is the level of detail

%p = 1.5;q = 1.5; sea_level = 80; iterations = 8; decay_fun = 1; mask_type = 2, mask_modifier = 1.5;  %volcanic islands
%p = 0.25;q = 1.1; sea_level = 100; iterations = 4; decay_fun = 2; mask_type = 1; mask_modifier = 1; %sandy banks
%p = 2.5; q = 1.3; sea_level = 0; iterations = 8; decay_fun = 1; mask_type = 0; %mountains and valleys
%p = 3; q = 1.1; sea_level = 0; iterations = 10; decay_fun = 1; mask_type = 2; mask_modifier = 0.75; %capitol peak


height_gradient = zeros([depth,width]);
compiled_heightmap = zeros([depth,width]);

for n = 1:iterations
    heightmap = 255.*noise([depth,width],depth./(8.*n));
    [gradx, grady] = gradient(heightmap);
    for j = 1:depth
        for i = 1:width
            height_gradient(j,i) = height_gradient(j,i) + sqrt(gradx(j,i).^2+grady(j,i).^2);
        end
    end
    switch decay_fun
        case 1
            layer{n} = heightmap.*(1./(1+p.*height_gradient)); %1/(1+km)
        case 2
            layer{n} = heightmap.*(exp(-p.*height_gradient.^2)); %e^(m^2)
    end
    %figure(n); imshow(layer{n},gray);
end
for k = 1:n
    compiled_heightmap = compiled_heightmap + layer{k}./(q^k);
end
compiled_heightmap = compiled_heightmap./max(max(compiled_heightmap));
compiled_heightmap = compiled_heightmap.*255;

%force sea
if sea_level > 0
    compiled_heightmap = compiled_heightmap - min(min(compiled_heightmap));
    compiled_heightmap = compiled_heightmap - sea_level;
    compiled_heightmap(compiled_heightmap<0) = 0;
end
%masking
if mask_type > 0
    msk = mask([depth,width],mask_type,mask_modifier);
    %imshow(msk)
    compiled_heightmap = compiled_heightmap.*msk;
    if mask_modifier < 1
        compiled_heightmap = 255.*compiled_heightmap./max(max(compiled_heightmap));
    end
end


%figure(n+1); imshow(compiled_heightmap,gray)

%imwrite(compiled_heightmap,gray,"test.png");


    function mask = mask(sz,type,mask_modifier)
        mask = zeros(sz);
        switch type
            case 1 %coast
                direction = randi([1 4],1);
                for j = 1:sz(1)
                    for i = 1:sz(2)
                        mask(j,i) = 1 - j./sz(1);
                    end
                end
                mask = mask./max(max(mask));

                mask = imrotate(mask,90*direction);
                if size(mask) ~= sz
                    mask = mask.';
                end
            case 2 %island
                depth = sz(1); width = sz(2);
                distance = zeros(sz);
                for j = 1:depth
                    for i = 1:width
                        h = depth./2;
                        k = width./2;
                        distance(j,i) = sqrt((j-h).^2+(i-k).^2);
                    end
                end
                mask(:,:) = 1 - mask_modifier.*distance(:,:)./max(max(distance));
                mask(mask<0) = 0;
        end

    end

end

