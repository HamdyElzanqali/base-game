local resource = {
    images = {},
    pathToImages = "",
}

-- load and cache an image
function resource:image(img, ...)
    img = self.pathToImages .. img

    if self.images[img] == nil then
        self.images[img] = love.graphics.newImage(img, ...)
    end

    return self.images[img]
end

-- TODO


return resource