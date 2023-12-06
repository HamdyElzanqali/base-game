local resource = {
    images = {},
    pathToImages = "",
    pathToObjects = "",
}

-- load and cache an image
function resource:image(img, ...)
    img = self.pathToImages .. img

    if self.images[img] == nil then
        self.images[img] = love.graphics.newImage(img, ...)
    end

    return self.images[img]
end

function resource:object(path)
    return require(self.pathToObjects .. path)
end

-- TODO


return resource