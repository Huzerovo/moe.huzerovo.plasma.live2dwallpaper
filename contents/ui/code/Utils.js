let plugin_name;

function set_plugin_name(name) {
    plugin_name = name;
}

function msg_error(msg) {
    console.error(plugin_name + "[error]: " + msg);
}

function msg_warn(msg) {
    console.warn(plugin_name + "[info]: " + msg);
}

function msg_info(msg) {
    console.info(plugin_name + "[info]: " + msg);
}

function objdump(obj) {
    msg_error("===================");
    for (var k of Object.keys(obj)) {
        msg_error(k + " = " + obj[k]);
    }
    msg_error("===================");
}
