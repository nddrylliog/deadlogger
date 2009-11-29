import structs/[ArrayList,HashMap]
import text/StringTokenizer

import deadlogger/[Level, Printer]

NoSuchLoggerError: class extends Exception {
    init: func ~withMsg (.msg) {
        super(msg)
    }
}

Logger: class {
    path: String
    subloggers: HashMap<Logger>
    printers: ArrayList<Printer>
    parent: Logger

    init: func (=path, =parent) {
        subloggers = HashMap<Logger> new()
        printers = ArrayList<Printer> new()
    }

    init: func ~withoutParent (.path) {
        this(path, null)
    }

    getSubLogger: func (path: String, create: Bool) -> Logger {
        if(path contains('.')) {
            idx := path indexOf('.')
            first := path substring(0, idx)
            rest := path substring(idx + 1, path length())
            return getSubLogger(first, false) getSubLogger(rest)
        } else {
            if(!subloggers contains(path)) {
                if(!create) {
                    NoSuchLoggerError new(This, "No such logger: '%s'" format(path)) throw()
                } else {
                    logger := Logger new(path, this)
                    subloggers put(path, logger)
                }
            }
            return subloggers get(path)
        }
    }

    attachPrinter: func (printer: Printer) {
        printers add(printer)
    }

    getSubLogger: func ~alwaysCreate (path: String) -> Logger {
        getSubLogger(path, true)
    }

    log: func (level: Int, emitter: Logger, msg: String) {
        accepted := false
        for(printer: Printer in printers) {
            if(printer print(level, emitter, msg)) {
                accepted = true
            }
        }
        if(!accepted) {
            if(parent) {
                parent log(level, emitter, msg)
            } else {
                /* TODO: lost! */
            }
        }
    }

    log: func ~emit (level: Int, msg: String) {
        log(level, this, msg)
    }

    debug: func (msg: String) {
        log(Level debug, msg)
    }

    info: func (msg: String) {
        log(Level info, msg)
    }

    warn: func (msg: String) {
        log(Level warn, msg)
    }

    error: func (msg: String) {
        log(Level error, msg)
    }

    critical: func (msg: String) {
        log(Level critical, msg)
    }
}
