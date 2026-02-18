const { writeFileSync, readdirSync, statSync, existsSync } = require('fs');
const { extname } = require("path");

exports('SaveResourceFile', async (resource_name, file_name, data, dataLen) => {
    try {
        // Verify the invoking resource is the current resource
        if (GetInvokingResource() != GetCurrentResourceName()) return 0;

        // Make sure the correct resource name is provided
        if (GetResourceState(resource_name) == "missing") return 0;

        // Get resource path
        const resource_path = GetResourcePath(resource_name);
        
        // Write to file
        await writeFileSync(`${resource_path}/${file_name}`, data, { encoding: 'utf-8' });

        return 1
    } catch (error) {
        return 0
    }
});

exports("exit", () => {
    // Verify the invoking resource is the current resource
    if (GetInvokingResource() != GetCurrentResourceName()) return 0;

    // Exit the server
    process.exit();
});

exports("GetFilePaths", async (resource_name, file_path) => {
    // Make sure the correct resource name/path is provided
    if (typeof resource_name != "string" || typeof file_path != "string" || GetResourceState(resource_name) == "missing") return [];

    // Get resource path
    const resource_path = GetResourcePath(resource_name);

    // Format the path/parse path
    const path = `${resource_path}/${file_path}`;

    const result = [];

    try {
        const normalizedPattern = path.replace(/\\/g, "/");
        const basePattern = normalizedPattern.split("/**/")[0];
        const targetFile = normalizedPattern.split("/**/").pop();
        const regex = new RegExp(targetFile.replace(/\*/g, '.*'));

        // Check if the core path exists
        if (!existsSync(basePattern)) return []

        // Check if the provided file path is just a file
        if (statSync(basePattern).isFile()) return [basePattern.replace(resource_path, "")];

        const traverse = (dir_path) => {
            const files = readdirSync(dir_path);
    
            for (const file of files) {
                const stats = statSync(`${dir_path}/${file}`);
    
                if (stats.isDirectory()) {
                    traverse(`${dir_path}/${file}`);
                } else if (file === targetFile || regex.test(file) || targetFile.replace(extname(file), "") == "*") result.push(`${dir_path}/${file}`.replace(resource_path, ""));
            };
        };

        traverse(basePattern);
    } catch (error) {
        // console.log(error)
        return []
    };

    return result;
});